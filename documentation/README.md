# Dokumentacija PlantTracker projekta

## Struktura dokumentacije

- `dokumentacija.tex` - Glavna LaTeX datoteka s potpunom dokumentacijom projekta
- `dokumentacija.pdf` - Kompajlirana PDF verzija (generira se)

## Kompajliranje LaTeX dokumentacije

### Online (Overleaf - preporučeno)

1. Otvori [Overleaf](https://www.overleaf.com)
2. Kreiraj novi projekt (Upload Project)
3. Upload `dokumentacija.tex` datoteku
4. Kompajliraj (Ctrl+S ili tipka Recompile)

### Lokalno (Linux/Mac)

Potreban je LaTeX distribucija (TeX Live ili MiKTeX):

```bash
# Instalacija na Ubuntu/Debian
sudo apt-get install texlive-full texlive-lang-european

# Kompajliranje
cd documentation
pdflatex dokumentacija.tex
pdflatex dokumentacija.tex  # Drugi put za ToC i reference
bibtex dokumentacija         # Za bibliografiju
pdflatex dokumentacija.tex  # Treći put za finalizaciju
```

### Windows

1. Instaliraj [MiKTeX](https://miktex.org/download)
2. Koristi TeXworks ili Texmaker editor
3. Otvori `dokumentacija.tex` i kompajliraj (F6 ili Ctrl+T)

## Struktura dokumentacije prema zahtjevima

Dokumentacija sadrži sve potrebne sekcije:

1. ✅ **Opis aplikacijske domene** - Koncepti, relacije, motivacija za tehnologiju
2. ✅ **Teorijski uvod** - Aktivne i temporalne baze podataka
3. ✅ **Model baze podataka** - ERA dijagram, opis tablica
4. ✅ **Implementacija** - SQL kod, triggers, funkcije, aplikacija
5. ✅ **Primjeri korištenja** - Konkretni primjeri s opisima
6. ✅ **Zaključak** - Procjena tehnologije, ograničenja
7. ✅ **Literatura** - IEEE stil citiranja

## Potrebne izmjene

Prije predaje, ažuriraj sljedeće:

- [ ] Upiši svoje ime i JMBAG u `\author{}`
- [ ] Dodaj ERA dijagram (koristi draw.io, pgModeler ili slično)
- [ ] Dodaj screenshot-e aplikacije u sekciju "Primjeri korištenja"
- [ ] Provjeri sve reference i citacije
- [ ] Provjeri numeriranje tablica i slika

## Upute za ERA dijagram

ERA dijagram možeš kreirati koristeći:

1. **draw.io** - https://app.diagrams.net/
2. **pgModeler** - https://pgmodeler.io/
3. **dbdiagram.io** - https://dbdiagram.io/

Izvezi kao PNG ili PDF i umetni u LaTeX koristeći:

```latex
\begin{figure}[H]
\centering
\includegraphics[width=0.9\textwidth]{era_diagram.png}
\caption{ERA dijagram PlantTracker aplikacije}
\label{fig:era}
\end{figure}
```

## Napomene

- Dokumentacija je pisana prema pravilima FOI-ja
- Koristi se IEEE stil citiranja
- Sve tablice i slike su numerirane
- Literatura je citirana u tekstu
