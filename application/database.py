"""
Database module za PlantTracker aplikaciju
Wrapper za PostgreSQL operacije
"""

import os
import psycopg2
from psycopg2.extras import RealDictCursor
from contextlib import contextmanager
from datetime import datetime
from dotenv import load_dotenv

load_dotenv()

class Database:
    """Klasa za upravljanje PostgreSQL bazom podataka"""
    
    def __init__(self):
        self.db_config = {
            'dbname': os.getenv('DB_NAME', 'planttracker'),
            'user': os.getenv('DB_USER', os.getenv('USER')),
            'password': os.getenv('DB_PASSWORD', ''),
            'host': os.getenv('DB_HOST', 'localhost'),
            'port': os.getenv('DB_PORT', '5432')
        }
    
    @contextmanager
    def get_connection(self):
        """Context manager za database konekciju"""
        conn = psycopg2.connect(**self.db_config)
        try:
            yield conn
        finally:
            conn.close()
    
    @contextmanager
    def get_cursor(self, dict_cursor=True):
        """Context manager za database cursor"""
        with self.get_connection() as conn:
            cursor_factory = RealDictCursor if dict_cursor else None
            cursor = conn.cursor(cursor_factory=cursor_factory)
            try:
                yield cursor
                conn.commit()
            except Exception:
                conn.rollback()
                raise
            finally:
                cursor.close()
    
    # ============================================
    # PLANTS
    # ============================================
    
    def get_plants_overview(self):
        """Dohvaća pregled svih biljaka"""
        with self.get_cursor() as cursor:
            cursor.execute("SELECT * FROM get_plants_overview()")
            return cursor.fetchall()
    
    def get_plant(self, plant_id):
        """Dohvaća detalje pojedine biljke"""
        with self.get_cursor() as cursor:
            cursor.execute("""
                SELECT * FROM plants WHERE plant_id = %s
            """, (plant_id,))
            return cursor.fetchone()
    
    def add_plant(self, common_name, scientific_name=None, variety=None, 
                  location=None, planting_date=None, acquisition_source=None, 
                  notes=None):
        """Dodaje novu biljku"""
        if not planting_date:
            planting_date = datetime.now().date()
        
        with self.get_cursor() as cursor:
            cursor.execute("""
                INSERT INTO plants (common_name, scientific_name, variety, 
                                  location, planting_date, acquisition_source, notes)
                VALUES (%s, %s, %s, %s, %s, %s, %s)
                RETURNING plant_id
            """, (common_name, scientific_name, variety, location, 
                  planting_date, acquisition_source, notes))
            result = cursor.fetchone()
            return result['plant_id']
    
    def update_plant(self, plant_id, data):
        """Ažurira biljku"""
        set_parts = []
        values = []
        
        for key in ['common_name', 'scientific_name', 'variety', 'location', 
                   'current_status', 'notes']:
            if key in data:
                set_parts.append(f"{key} = %s")
                values.append(data[key])
        
        if not set_parts:
            return
        
        values.append(plant_id)
        query = f"UPDATE plants SET {', '.join(set_parts)} WHERE plant_id = %s"
        
        with self.get_cursor() as cursor:
            cursor.execute(query, values)
    
    def delete_plant(self, plant_id):
        """Briše biljku"""
        with self.get_cursor() as cursor:
            cursor.execute("DELETE FROM plants WHERE plant_id = %s", (plant_id,))
    
    # ============================================
    # EVENTS
    # ============================================
    
    def get_plant_events(self, plant_id, limit=50):
        """Dohvaća događaje za biljku"""
        with self.get_cursor() as cursor:
            cursor.execute("""
                SELECT * FROM events 
                WHERE plant_id = %s 
                ORDER BY event_date DESC 
                LIMIT %s
            """, (plant_id, limit))
            return cursor.fetchall()
    
    def add_event(self, plant_id, event_type, description=None, 
                  amount=None, performed_by=None):
        """Dodaje novi događaj"""
        with self.get_cursor() as cursor:
            cursor.execute("""
                INSERT INTO events (plant_id, event_type, description, amount, performed_by)
                VALUES (%s, %s, %s, %s, %s)
                RETURNING event_id
            """, (plant_id, event_type, description, amount, performed_by))
            result = cursor.fetchone()
            return result['event_id']
    
    # ============================================
    # REMINDERS
    # ============================================
    
    def get_plant_reminders(self, plant_id):
        """Dohvaća podsjetnika za biljku"""
        with self.get_cursor() as cursor:
            cursor.execute("""
                SELECT * FROM reminders 
                WHERE plant_id = %s 
                ORDER BY next_due
            """, (plant_id,))
            return cursor.fetchall()
    
    def get_active_reminders(self):
        """Dohvaća sve aktivne podsjetnika"""
        with self.get_cursor() as cursor:
            cursor.execute("""
                SELECT r.*, p.common_name 
                FROM reminders r
                JOIN plants p ON r.plant_id = p.plant_id
                WHERE r.is_active = TRUE
                ORDER BY r.next_due
            """)
            return cursor.fetchall()
    
    def get_overdue_reminders(self):
        """Dohvaća dospjele podsjetnika"""
        with self.get_cursor() as cursor:
            cursor.execute("SELECT * FROM overdue_reminders")
            return cursor.fetchall()
    
    def add_reminder(self, plant_id, reminder_type, frequency, next_due=None):
        """Dodaje novi podsjetnik"""
        with self.get_cursor() as cursor:
            cursor.execute("""
                INSERT INTO reminders (plant_id, reminder_type, frequency, next_due)
                VALUES (%s, %s, %s, COALESCE(%s, CURRENT_TIMESTAMP))
                RETURNING reminder_id
            """, (plant_id, reminder_type, frequency, next_due))
            result = cursor.fetchone()
            return result['reminder_id']
    
    def delete_reminder(self, reminder_id):
        """Briše podsjetnik"""
        with self.get_cursor() as cursor:
            cursor.execute("DELETE FROM reminders WHERE reminder_id = %s", (reminder_id,))
    
    # ============================================
    # NOTIFICATIONS
    # ============================================
    
    def get_unread_notifications(self, limit=20):
        """Dohvaća nepročitane notifikacije"""
        with self.get_cursor() as cursor:
            cursor.execute("""
                SELECT * FROM notifications 
                WHERE is_read = FALSE 
                ORDER BY created_at DESC 
                LIMIT %s
            """, (limit,))
            return cursor.fetchall()
    
    def mark_notification_read(self, notification_id):
        """Označava notifikaciju kao pročitanu"""
        with self.get_cursor() as cursor:
            cursor.execute("""
                UPDATE notifications 
                SET is_read = TRUE, read_at = CURRENT_TIMESTAMP 
                WHERE notification_id = %s
            """, (notification_id,))
    
    # ============================================
    # IMAGES
    # ============================================
    
    def get_plant_images(self, plant_id):
        """Dohvaća slike biljke"""
        with self.get_cursor() as cursor:
            cursor.execute("""
                SELECT * FROM images 
                WHERE plant_id = %s 
                ORDER BY taken_at DESC
            """, (plant_id,))
            return cursor.fetchall()
    
    # ============================================
    # GROWTH MEASUREMENTS
    # ============================================
    
    def add_measurement(self, plant_id, height_cm=None, width_cm=None, 
                       leaf_count=None, flower_count=None, notes=None):
        """Dodaje mjerenje rasta"""
        with self.get_cursor() as cursor:
            cursor.execute("""
                INSERT INTO growth_measurements 
                (plant_id, height_cm, width_cm, leaf_count, flower_count, notes)
                VALUES (%s, %s, %s, %s, %s, %s)
                RETURNING measurement_id
            """, (plant_id, height_cm, width_cm, leaf_count, flower_count, notes))
            result = cursor.fetchone()
            return result['measurement_id']
    
    def get_growth_trend(self, plant_id, days=30):
        """Dohvaća trend rasta"""
        with self.get_cursor() as cursor:
            cursor.execute("SELECT * FROM get_growth_trend(%s, %s)", (plant_id, days))
            return cursor.fetchall()
    
    # ============================================
    # TEMPORAL QUERIES
    # ============================================
    
    def get_status_history(self, plant_id, from_date, to_date):
        """Dohvaća povijest statusa (temporalni upit)"""
        with self.get_cursor() as cursor:
            cursor.execute("""
                SELECT * FROM get_status_history(%s, %s, %s)
            """, (plant_id, from_date, to_date))
            return cursor.fetchall()
    
    def get_plant_status_at(self, plant_id, timestamp):
        """Dohvaća status biljke u određenom trenutku"""
        with self.get_cursor() as cursor:
            cursor.execute("SELECT get_plant_status_at(%s, %s)", (plant_id, timestamp))
            result = cursor.fetchone()
            return result[0] if result else None
    
    # ============================================
    # REPORTS & STATISTICS
    # ============================================
    
    def get_plant_report(self, plant_id):
        """Generira izvještaj o biljci"""
        with self.get_cursor() as cursor:
            cursor.execute("SELECT * FROM generate_plant_report(%s)", (plant_id,))
            return cursor.fetchone()
    
    def get_dashboard_stats(self):
        """Dohvaća statistike za dashboard"""
        with self.get_cursor() as cursor:
            cursor.execute("""
                SELECT 
                    (SELECT COUNT(*) FROM plants) as total_plants,
                    (SELECT COUNT(*) FROM plants WHERE current_status = 'zdrava') as healthy_plants,
                    (SELECT COUNT(*) FROM overdue_reminders) as overdue_reminders,
                    (SELECT COUNT(*) FROM notifications WHERE is_read = FALSE) as unread_notifications,
                    (SELECT COUNT(*) FROM events WHERE event_date > CURRENT_TIMESTAMP - INTERVAL '7 days') as events_this_week
            """)
            return cursor.fetchone()
