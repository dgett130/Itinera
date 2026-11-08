# Script delle maschere

Strumenti per disegnare le maschere di Itinera in FigCraft
(`docs/design/itinera-identita.figcraft`). Regola del progetto: ogni modifica
grafica si disegna prima qui, poi si porta nel codice.

## Prerequisiti
- FigCraft aperto dal collegamento sul desktop **«FigCraft (Claude)»**, che
  abilita la porta di controllo 47920 (`--control 47920`).
- Python 3 con questa cartella come directory corrente.

## File
- `figcraft_kit.py`: colori Cartolina, icone, helper per schermate, testate,
  schede, campi, fogli e bottoni (`Doc`), collegamento all'app (`Client`) e
  `publish()`, che sostituisce una pagina intera e salva il file.
  Lanciato da solo elenca le pagine del file aperto: serve a verificare il
  collegamento.
- `city.py`: la scena Città del poster, con le stesse coordinate del codice.

## Uso
```python
from figcraft_kit import *

d = Doc()
r = d.screen("Esempio", 0)
d.header(r, SOLE, "Valigia", "23 di 40 pronti")
publish(d, "Esempio", "Z · Prove")
```
Con `DARK=1` lo stesso script disegna la versione scura nella pagina
«Z · Prove · scuro».

Gli script di ogni nuova pagina vanno salvati in questa cartella.
