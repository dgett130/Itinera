# Pagina K, fila 10: il movimento della scheda "Oggi" (modalita' In viaggio).
# Si aggiunge in fondo alla pagina K senza toccare le altre file (vedi append()).
# Le schede si costruiscono con le funzioni di p_in_viaggio.py.
from figcraft_kit import *
import p_in_viaggio as pv

TAG = "· in viaggio"
STEP = 452
Y10 = 9432 + 2600  # sotto le file 8 e 9 del poster vivo
ANN = SOLE

d = Doc()
pv.d = d  # le funzioni della pagina P disegnano in questo doc

d.node("text", None, f"Titolo fila {TAG}", x=0, y=Y10, text="10 · In viaggio", fontFamily=BRI, fontStyle="ExtraBold", fontSize=30, fill=INK)
d.node("text", None, f"Nota fila {TAG}", x=0, y=Y10 + 38, w=2200, text="La scheda «Oggi» si muove poco e solo quando cambia qualcosa: «adesso» scivola ogni minuto, un'attività che finisce si spunta, la prossima prende il suo posto. Mai animazioni in ciclo. Con «Riduci animazioni» i cambi avvengono di colpo.", fontFamily=FIG, fontStyle="Regular", fontSize=16, fill=MUTED)


def frame(i, name, caption):
    f = d.node("frame", None, f"{name} {TAG}", x=STEP * i, y=Y10 + 90, w=412, fill=CARTA, cornerRadius=28, layout="vertical", gap=14, padding=[20, 20, 20, 20], sizingV="hug", clip=True)
    d.text(f, caption, FIG, "Regular", 13.5, MUTED, fillw=True)
    return f


def spec(f, title, lines):
    c = d.frame(f, "Tempi", gap=8, pad=[16, 18, 18, 18], fill=WHITE, cornerRadius=20, stroke=HAIR, strokeWeight=1)
    d.text(c, title, BRI, "Bold", 17, INK)
    for k, v in lines:
        row = d.row(c, "Riga", gap=10, H="fill", cross="min")
        d.text(row, k, FIG, "SemiBold", 14, INK, w=104)
        d.text(row, v, FIG, "Regular", 14, MUTED, fillw=True)


def tag(f, x, y, s, bg=ANN, fg=INK):
    """Etichetta del movimento, sopra la scheda."""
    t = d.node("frame", f, "Etichetta", x=x, y=y, fill=bg, cornerRadius=10, layout="horizontal", padding=[3, 8, 3, 8], sizingH="hug", sizingV="hug", absolute=True)
    d.node("text", t, "Testo", text=s, fontFamily=BRI, fontStyle="Bold", fontSize=13, fill=fg)
    return t


def arrow(f, pts, color=ANN, w=3):
    import math
    xs, ys = [p[0] for p in pts], [p[1] for p in pts]
    path = f"M{pts[0][0]} {pts[0][1]} " + " ".join(f"L{x} {y}" for x, y in pts[1:])
    (xa, ya), (xb, yb) = pts[-2], pts[-1]
    a = math.atan2(yb - ya, xb - xa)
    h1 = (xb - 10 * math.cos(a - 0.5), yb - 10 * math.sin(a - 0.5))
    h2 = (xb - 10 * math.cos(a + 0.5), yb - 10 * math.sin(a + 0.5))
    path += f" M{h1[0]:.1f} {h1[1]:.1f} L{xb} {yb} L{h2[0]:.1f} {h2[1]:.1f}"
    d.node("vector", f, "Traccia", x=0, y=0, path=path, fill="none", stroke=color, strokeWeight=w, strokeCap="round", strokeJoin="round", absolute=True)


# ---------- 1. "adesso" scivola
f = frame(0, "Oggi / Adesso", "«Adesso» scende sul binario seguendo l'ora della destinazione: tra la fine di un'attività e l'inizio della successiva, in proporzione.")
c = pv.today(f)
pv.next_block(c, "PROSSIMA · TRA 40 MIN", "Galleria Borghese", "16:30 · Piazzale Scipione Borghese 5")
pv.day(c, 2, "15:50", pv.roma(["done", "done", "done", "todo", "todo"]))
arrow(f, [(372, 452), (372, 522)])
tag(f, 268, 476, "ogni minuto")
spec(f, "«Adesso»", [("Posizione", "dall'ora locale, tra fine e inizio"), ("Aggiornamento", "ogni minuto, scivola in 240 ms"), ("All'apertura", "già al suo posto, nessun salto")])

# ---------- 2. Un'attivita' finisce
f = frame(1, "Oggi / Fatta", "Quando un'attività finisce il pallino diventa la spunta con uno scatto, il testo si spegne e il riquadro giallo passa alla successiva.")
c = pv.today(f)
pv.next_block(c, "PROSSIMA · TRA 2 ORE", "Galleria Borghese", "16:30 · Piazzale Scipione Borghese 5")
pv.day(c, 2, "14:30", pv.roma(["done", "done", "done", "todo", "todo"]))
tag(f, 292, 392, "spunta · 280 ms")
arrow(f, [(398, 230), (398, 168)])
tag(f, 226, 144, "esce in alto · 360 ms")
spec(f, "Fatta", [("Spunta", "scatto 0 → 1,15 → 1 in 280 ms"), ("Testo", "si spegne in 240 ms"), ("Riquadro", "il vecchio esce in alto, il nuovo entra dal basso, 360 ms"), ("Vibrazione", "nessuna: succede da sé")])

# ---------- 3. Conto alla rovescia e attivita' in corso
f = frame(2, "Oggi / In corso", "Il conto alla rovescia cambia ogni minuto con le cifre che scorrono. All'inizio dell'attività il riquadro diventa «In corso» e la barra avanza.")
c = pv.today(f)
pv.next_block(c, "IN CORSO · FINISCE TRA 50 MIN", "Pranzo da Roscioli", "fino alle 14:30 · poi Galleria Borghese alle 16:30", progress=0.45, nav=False)
pv.day(c, None, "", pv.roma(["done", "done", "now", "todo", "todo"]))
tag(f, 262, 172, "cifre · 200 ms")
tag(f, 236, 246, "barra · ogni minuto")
spec(f, "Il tempo", [("Minuti", "le cifre scorrono in alto, 200 ms"), ("Sotto 1 min", "«adesso», poi «In corso»"), ("Barra", "avanza ogni minuto, 240 ms"), ("Pallino", "in corso: corallo col cuore bianco")])

# ---------- 4. Fine giornata
f = frame(3, "Oggi / Sera", "Dopo l'ultima attività il riquadro sfuma in laguna su domani e la giornata si chiude nella riga «5 su 5»; «mostra» la riapre.")
c = pv.today(f)
pv.next_block(c, "DOMANI · DOM 26 OTTOBRE", "Musei Vaticani alle 09:30", "4 attività · ultimo giorno", color=LAG, nav=False)
sumr = d.row(c, "Fatte", gap=10, H="fill")
dot = d.node("frame", sumr, "Pallino", w=22, h=22, fill=POS, cornerRadius=11, layout="horizontal", mainAlign="center", crossAlign="center")
d.icon(dot, "check", WHITE, 15)
d.text(sumr, "Oggi 5 attività su 5", FIG, "SemiBold", 15.5, INK, fillw=True)
d.text(sumr, "mostra", BRI, "Bold", 14, COB)
tag(f, 250, 128, "giallo → laguna · 360 ms")
tag(f, 200, 276, "si richiude · 360 ms")
spec(f, "Si chiude", [("Riquadro", "giallo → laguna in dissolvenza, 360 ms"), ("Giornata", "si richiude in altezza, 360 ms"), ("Quando", "alla fine dell'ultima attività")])

# ---------- 5. Oggi | Domani e spunta a mano
f = frame(4, "Oggi / Domani", "«Domani» fa scorrere la giornata verso sinistra; «Oggi» la riporta. Le attività senza orario si spuntano a mano, con la vibrazione.")
c = pv.today(f, "dom 26 ottobre · ultimo giorno", tab=1)
pv.next_block(c, "LA PRIMA · ALLE 09:30", "Musei Vaticani", "Viale Vaticano · 4 attività in tutto", color=LAG)
g = d.frame(c, "Giornata", gap=6)
for k, it in enumerate([("09:30", "12:30", "Musei Vaticani", "Viale Vaticano"), ("13:00", None, "Pranzo in Prati", "Via Cola di Rienzo"), ("15:00", None, "Castel Sant'Angelo", "Lungotevere Castello 50"), ("19:40", None, "Treno per Milano", "Roma Termini")]):
    pv.step(g, *it, "todo", last=k == 3)
arrow(f, [(388, 300), (300, 300)])
tag(f, 236, 266, "scorre di lato · 300 ms")
spec(f, "Gesti", [("Oggi | Domani", "la giornata scorre di lato, 300 ms; scatto di selezione"), ("Spunta a mano", "cerchio → spunta 280 ms; vibrazione leggera"), ("Riapertura", "torna sempre su Oggi")])

# ---------- 6. Entrata e Riduci animazioni
f = frame(5, "Oggi / Entrata", "All'apertura della Home la scheda entra dopo il poster, come gli altri elementi (StaggerIn). Con «Riduci animazioni» tutto cambia di colpo.")
c = pv.today(f)
pv.next_block(c, "PROSSIMA · TRA 25 MIN", "Colazione al Gianicolo", "09:00 · Passeggiata del Gianicolo")
pv.day(c, -1, "08:35", pv.roma(["todo"] * 5))
arrow(f, [(392, 150), (392, 100)])
tag(f, 110, 96, "sale e appare · 360 ms")
spec(f, "Entrata", [("Scheda", "dopo il poster, indice 1 di StaggerIn"), ("Righe", "ferme: entra la scheda intera"), ("Riduci animazioni", "nessun movimento, cambi di colpo")])

append(d, "K In viaggio", "K · Movimento", TAG)
