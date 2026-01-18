"""
PlantTracker - Flask Web Application
Aplikacija za praćenje i pomoć u održavanju rasta biljaka
"""

import os
from flask import Flask, render_template, request, jsonify, redirect, url_for
from datetime import datetime
from database import Database

app = Flask(__name__)
app.config['SECRET_KEY'] = os.getenv('SECRET_KEY', 'dev-secret-key')
app.config['UPLOAD_FOLDER'] = os.getenv('UPLOAD_FOLDER', 'static/uploads')

# Inicijalizacija baze podataka
db = Database()

# ============================================
# WEB ROUTES
# ============================================

@app.route('/')
def index():
    """Početna stranica s pregledom svih biljaka"""
    try:
        plants = db.get_plants_overview()
        stats = db.get_dashboard_stats()
        return render_template('index.html', plants=plants, stats=stats)
    except Exception as e:
        return render_template('error.html', error=str(e)), 500

@app.route('/plant/add')
def add_plant_page():
    """Stranica za dodavanje nove biljke"""
    return render_template('add_plant.html')

@app.route('/plant/<plant_id>')
def plant_detail(plant_id):
    """Detaljna stranica pojedine biljke"""
    try:
        plant = db.get_plant(plant_id)
        if not plant:
            return render_template('error.html', error='Biljka nije pronađena'), 404
        
        report = db.get_plant_report(plant_id)
        events = db.get_plant_events(plant_id, limit=20)
        reminders = db.get_plant_reminders(plant_id)
        images = db.get_plant_images(plant_id)
        growth = db.get_growth_trend(plant_id, days=90)
        
        return render_template('plant_detail.html', 
                             plant=plant,
                             report=report,
                             events=events,
                             reminders=reminders,
                             images=images,
                             growth=growth)
    except Exception as e:
        return render_template('error.html', error=str(e)), 500

@app.route('/plant/<plant_id>/history')
def plant_history(plant_id):
    """Temporalna povijest biljke"""
    try:
        from_date = request.args.get('from', '2024-01-01')
        to_date = request.args.get('to', datetime.now().strftime('%Y-%m-%d'))
        
        history = db.get_status_history(plant_id, from_date, to_date)
        plant = db.get_plant(plant_id)
        
        return render_template('plant_history.html', 
                             plant=plant,
                             history=history,
                             from_date=from_date,
                             to_date=to_date)
    except Exception as e:
        return render_template('error.html', error=str(e)), 500

@app.route('/reminders')
def reminders():
    """Stranica s aktivnim podsjetnicima"""
    try:
        active_reminders = db.get_active_reminders()
        overdue_reminders = db.get_overdue_reminders()
        notifications = db.get_unread_notifications()
        
        return render_template('reminders.html',
                             active_reminders=active_reminders,
                             overdue_reminders=overdue_reminders,
                             notifications=notifications)
    except Exception as e:
        return render_template('error.html', error=str(e)), 500

# ============================================
# API ROUTES
# ============================================

@app.route('/api/plants', methods=['GET'])
def api_get_plants():
    """API: Dohvati sve biljke"""
    try:
        plants = db.get_plants_overview()
        return jsonify({'success': True, 'plants': plants})
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/plant', methods=['POST'])
def api_add_plant():
    """API: Dodaj novu biljku"""
    try:
        data = request.get_json()
        plant_id = db.add_plant(
            common_name=data['common_name'],
            scientific_name=data.get('scientific_name'),
            variety=data.get('variety'),
            location=data.get('location'),
            planting_date=data['planting_date'],
            acquisition_source=data.get('acquisition_source'),
            notes=data.get('notes')
        )
        return jsonify({'success': True, 'plant_id': str(plant_id)})
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 400

@app.route('/api/plant/<plant_id>', methods=['PUT'])
def api_update_plant(plant_id):
    """API: Ažuriraj biljku"""
    try:
        data = request.get_json()
        db.update_plant(plant_id, data)
        return jsonify({'success': True})
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 400

@app.route('/api/plant/<plant_id>', methods=['DELETE'])
def api_delete_plant(plant_id):
    """API: Obriši biljku"""
    try:
        db.delete_plant(plant_id)
        return jsonify({'success': True})
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 400

@app.route('/api/event', methods=['POST'])
def api_add_event():
    """API: Dodaj događaj (zalijevanje, gnojenje, itd.)"""
    try:
        data = request.get_json()
        event_id = db.add_event(
            plant_id=data['plant_id'],
            event_type=data['event_type'],
            description=data.get('description'),
            amount=data.get('amount'),
            performed_by=data.get('performed_by')
        )
        return jsonify({'success': True, 'event_id': event_id})
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 400

@app.route('/api/reminder', methods=['POST'])
def api_add_reminder():
    """API: Dodaj podsjetnik"""
    try:
        data = request.get_json()
        reminder_id = db.add_reminder(
            plant_id=data['plant_id'],
            reminder_type=data['reminder_type'],
            frequency=data['frequency'],
            next_due=data.get('next_due')
        )
        return jsonify({'success': True, 'reminder_id': reminder_id})
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 400

@app.route('/api/reminder/<reminder_id>', methods=['DELETE'])
def api_delete_reminder(reminder_id):
    """API: Obriši podsjetnik"""
    try:
        db.delete_reminder(reminder_id)
        return jsonify({'success': True})
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 400

@app.route('/api/notification/<notification_id>/read', methods=['POST'])
def api_mark_notification_read(notification_id):
    """API: Označi notifikaciju kao pročitanu"""
    try:
        db.mark_notification_read(notification_id)
        return jsonify({'success': True})
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 400

@app.route('/api/measurement', methods=['POST'])
def api_add_measurement():
    """API: Dodaj mjerenje rasta"""
    try:
        data = request.get_json()
        measurement_id = db.add_measurement(
            plant_id=data['plant_id'],
            height_cm=data.get('height_cm'),
            width_cm=data.get('width_cm'),
            leaf_count=data.get('leaf_count'),
            flower_count=data.get('flower_count'),
            notes=data.get('notes')
        )
        return jsonify({'success': True, 'measurement_id': measurement_id})
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 400

# ============================================
# ERROR HANDLERS
# ============================================

@app.errorhandler(404)
def not_found(error):
    return render_template('error.html', error='Stranica nije pronađena'), 404

@app.errorhandler(500)
def internal_error(error):
    return render_template('error.html', error='Interna greška poslužitelja'), 500

# ============================================
# MAIN
# ============================================

if __name__ == '__main__':
    # Kreiranje potrebnih direktorija
    os.makedirs(app.config['UPLOAD_FOLDER'], exist_ok=True)
    
    print("=" * 50)
    print("PlantTracker - Web Application")
    print("=" * 50)
    print(f"Running on: http://localhost:5000")
    print(f"Database: {os.getenv('DB_NAME', 'planttracker')}")
    print("=" * 50)
    
    app.run(debug=True, host='0.0.0.0', port=5000)
