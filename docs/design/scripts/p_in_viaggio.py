# Pagina P: modalita' "In viaggio". Dal giorno di partenza a quello di rientro,
# sotto il poster della Home compare la scheda "Oggi": la giornata
# dell'itinerario con l'indicatore "adesso" (ora della destinazione), la
# prossima attivita' e quanto manca, le scorciatoie Spesa e Tabella di marcia.
# Tutto offline: usa solo l'itinerario sul telefono.
# Il movimento e' nella pagina K (k_in_viaggio.py). DARK=1 per la variante scura.
from figcraft_kit import *
from poster_kit import Poster

I["nav"] = "M12 2L4.5 20.29l.71.71L12 18l6.79 3 .71-.71z"
I["sun"] = "M6.76 4.84l-1.8-1.79-1.41 1.41 1.79 1.79 1.42-1.41zM4 10.5H1v2h3v-2zm9-9.95h-2V3.5h2V.55zm7.45 3.91l-1.41-1.41-1.79 1.79 1.41 1.41 1.79-1.79zm-3.21 13.7l1.79 1.8 1.41-1.41-1.8-1.79-1.4 1.4zM20 10.5v2h3v-2h-3zm-8-5c-3.31 0-6 2.69-6 6s2.69 6 6 6 6-2.69 6-6-2.69-6-6-6zm-1 16.95h2V19.5h-2v2.95zm-7.45-3.91l1.41 1.41 1.79-1.8-1.41-1.41-1.79 1.8z"

d = Doc()
STEP = 452
SH = 1060  # schermata intera: la Home scorre
NOW = FEN  # l'indicatore "adesso"

d.node("text", None, "Titolo pagina", x=0, y=-150, text="In viaggio", fontFamily=BRI, fontStyle="ExtraBold", fontSize=34, fill=d.on)
d.node("text", None, "Flusso", x=0, y=-104, w=2200, text="Dal giorno di partenza a quello di rientro, sotto il poster del viaggio in corso compare la scheda «Oggi»: le attività del giorno con l'indicatore «adesso» (ora della destinazione), la prossima attività e quanto manca, Indicazioni verso il luogo, le scorciatoie Spesa e Tabella di marcia. Tutto dall'itinerario sul telefono, anche senza rete. Fuori dalle date del viaggio la Home resta com'è. Schermate intere: la Home scorre.", fontFamily=FIG, fontStyle="Regular", fontSize=16, fill=d.muted)


def home(i, name, caption):
    r = d.screen(f"Home / {name}", STEP * i, h=SH, pad=[0, 20, 40, 20], gap=12)
    d.node("text", None, "Didascalia", x=STEP * i, y=d.y0 + SH + 12, w=412, text=caption, fontFamily=FIG, fontStyle="Regular", fontSize=13, fill=d.muted)
    hd = d.frame(r, "Testata", gap=2, pad=[40, 0, 0, 0])
    bar = d.row(hd, "Barra", main="spaceBetween", H="fill")
    d.text(bar, "Itinera", BRI, "ExtraBold", 22, d.accent)
    a = d.row(bar, "Azioni", gap=18, H="hug")
    for ic in ("bell", "people", "gear"):
        d.icon(a, ic, d.on, 22)
    d.text(hd, "I miei viaggi", BRI, "ExtraBold", 38, d.on, lh=42)
    card = d.node("frame", r, "Poster", w=372, h=340, fill="none", clip=True, cornerRadius=24, sizingH="fixed", sizingV="fixed")
    p = Poster(d, card)
    p.sky(FEN)
    p.circle(p.X(300), p.Y(84), 34, SOLE, "Sole")
    p.city(FEN, back=COB, front=COBD)
    p.texts("Weekend a Roma", "Roma, Italia", "in corso", INK, WHITE, "sun", "22°")
    return r


def today(parent, date="sab 25 ottobre · giorno 3 di 4", tab=0):
    """La scheda Oggi: testa con Oggi | Domani."""
    c = d.frame(parent, "Oggi", gap=14, pad=[16, 16, 16, 16], fill=d.card_bg, stroke=d.hair, strokeWeight=1, cornerRadius=24)
    top = d.row(c, "Testa", main="spaceBetween", H="fill", cross="center")
    t = d.frame(top, "Testi", gap=0, H="fill")
    d.text(t, "Oggi" if tab == 0 else "Domani", BRI, "ExtraBold", 24, d.on)
    d.note(t, date, size=13)
    seg = d.frame(top, "Oggi | Domani", "horizontal", 0, 3, d.bg, H="hug", cornerRadius=18, stroke=d.hair, strokeWeight=1)
    for k, s in enumerate(("Oggi", "Domani")):
        cell = d.frame(seg, s, "horizontal", 0, [6, 12, 6, 12], d.cta_bg if k == tab else "none", H="hug", cornerRadius=15)
        d.text(cell, s, BRI, "Bold", 13, d.on_cta if k == tab else d.on)
    return c


def next_block(parent, kicker, title, sub, progress=None, color=SOLE, nav=True):
    """La prossima attivita' (o quella in corso) in evidenza."""
    b = d.frame(parent, "Prossima", "horizontal", 12, [14, 14, 14, 16], color, cornerRadius=20, crossAlign="center")
    t = d.frame(b, "Testi", gap=3, H="fill")
    d.text(t, kicker, FIG, "Bold", 12.5, INK, fillw=True)
    d.text(t, title, BRI, "ExtraBold", 21, INK, fillw=True, lh=24)
    d.text(t, sub, FIG, "Medium", 13.5, INK, fillw=True)
    if progress is not None:
        bar = d.frame(t, "Avanzamento", "horizontal", 0, 0, "#11153A26", h=6, cornerRadius=3)
        d.node("frame", bar, "Fatto", w=round(220 * progress), h=6, fill=INK, cornerRadius=3, sizingH="fixed", sizingV="fixed")
    if nav:
        n = d.frame(b, "Indicazioni", "vertical", 3, 0, "none", H="hug", crossAlign="center")
        btn = d.node("frame", n, "Tasto", w=48, h=48, fill=INK, cornerRadius=24, layout="horizontal", mainAlign="center", crossAlign="center")
        d.icon(btn, "nav", color if color != INK else SOLE, 22)
        d.text(n, "Vai", FIG, "Bold", 11.5, INK)
    return b


def step(parent, time, end, title, place, state="todo", last=False, timed=True):
    """Una riga della giornata: ora, binario con il pallino, testi.
    state: done | todo | now (in corso) | free (senza orario)."""
    done = state == "done"
    row = d.frame(parent, title, "horizontal", 10, 0, "none", crossAlign="min")
    tc = d.frame(row, "Ora", gap=0, w=46, H="fixed") if timed else None
    if time:
        d.text(tc, time, BRI, "Bold", 15, d.muted if done else d.on)
        if end:
            d.text(tc, end, FIG, "Regular", 12, d.muted)
    rail = d.frame(row, "Binario", gap=0, w=22, H="fixed", crossAlign="center")
    if done:
        dot = d.node("frame", rail, "Pallino", w=22, h=22, fill=d.pos, cornerRadius=11, layout="horizontal", mainAlign="center", crossAlign="center")
        d.icon(dot, "check", WHITE, 15)
    elif state == "now":
        dot = d.node("frame", rail, "Pallino", w=22, h=22, fill=NOW, cornerRadius=11, layout="horizontal", mainAlign="center", crossAlign="center")
        d.node("frame", dot, "Cuore", w=8, h=8, fill=WHITE, cornerRadius=4)
    else:
        d.node("frame", rail, "Pallino", w=22, h=22, fill=d.card_bg, stroke=d.on if state == "free" else d.muted, strokeWeight=2, cornerRadius=11)
    if not last:
        d.node("frame", rail, "Linea", w=2, h=34, fill=d.hair, sizingH="fixed", sizingV="fixed")
    tx = d.frame(row, "Testi", gap=1, H="fill", pad=[1, 0, 0, 0])
    d.text(tx, title, FIG, "SemiBold", 15.5, d.muted if done else d.on, fillw=True)
    if place:
        d.text(tx, place, FIG, "Regular", 13, d.muted, fillw=True)
    return row


def now_line(parent, time):
    """L'indicatore "adesso": pillola con l'ora sul binario e riga corallo."""
    r = d.frame(parent, "Adesso", "horizontal", 0, 0, crossAlign="center")
    p = d.frame(r, "Ora", "horizontal", 0, [3, 8, 3, 8], NOW, H="hug", cornerRadius=10)
    d.text(p, time, BRI, "Bold", 12.5, INK)
    d.node("frame", r, "Riga", h=2, fill=NOW, sizingH="fill", sizingV="fixed")
    return r


def actions(parent):
    r = d.row(parent, "Scorciatoie", gap=8, H="fill")
    s = d.frame(r, "Spesa", "horizontal", 6, [10, 16, 10, 12], SOLE, H="hug", cornerRadius=22, crossAlign="center")
    d.icon(s, "plus", INK, 18)
    d.text(s, "Spesa", BRI, "Bold", 15, INK)
    m = d.frame(r, "Tabella di marcia", "horizontal", 6, [10, 16, 10, 12], "none", H="hug", cornerRadius=22, stroke=d.on, strokeWeight=1.5, crossAlign="center")
    d.icon(m, "calendar", d.on, 18)
    d.text(m, "Tabella di marcia", BRI, "Bold", 15, d.on)
    return r


def day(c, now_after, now_time, items):
    g = d.frame(c, "Giornata", gap=6)
    if now_after == -1:
        now_line(g, now_time)
    for k, it in enumerate(items):
        step(g, *it, last=k == len(items) - 1)
        if k == now_after:
            now_line(g, now_time)


ROMA = [
    ("09:00", "10:00", "Colazione al Gianicolo", "Passeggiata del Gianicolo"),
    ("10:30", "12:30", "Musei Capitolini", "Piazza del Campidoglio"),
    ("13:00", "14:30", "Pranzo da Roscioli", "Via dei Giubbonari 21"),
    ("16:30", "18:30", "Galleria Borghese", "Piazzale Scipione Borghese 5"),
    ("20:00", None, "Cena a Trastevere", "Da Enzo al 29"),
]


def roma(states):
    return [(t, e, ti, pl, s) for (t, e, ti, pl), s in zip(ROMA, states)]


# ---------- 1. Mattina: prima della prima attivita'
r = home(0, "In viaggio · mattina", "Mattina, prima di tutto: «adesso» in cima, la prima attività in evidenza con quanto manca.")
c = today(r)
next_block(c, "PROSSIMA · TRA 25 MIN", "Colazione al Gianicolo", "09:00 · Passeggiata del Gianicolo")
day(c, -1, "08:35", roma(["todo"] * 5))
actions(c)

# ---------- 2. Pomeriggio: tra un'attivita' e l'altra
r = home(1, "In viaggio · pomeriggio", "Tra due attività: le passate sono spente con la spunta, «adesso» scorre sul binario, la prossima è in evidenza.")
c = today(r)
next_block(c, "PROSSIMA · TRA 40 MIN", "Galleria Borghese", "16:30 · Piazzale Scipione Borghese 5")
day(c, 2, "15:50", roma(["done", "done", "done", "todo", "todo"]))
actions(c)

# ---------- 3. Durante un'attivita'
r = home(2, "In viaggio · in corso", "Durante un'attività: in evidenza quella in corso, con quanto manca alla fine e la barra che avanza.")
c = today(r)
next_block(c, "IN CORSO · FINISCE TRA 50 MIN", "Pranzo da Roscioli", "fino alle 14:30 · poi Galleria Borghese alle 16:30", progress=0.45, nav=False)
day(c, None, "", roma(["done", "done", "now", "todo", "todo"]))
actions(c)

# ---------- 4. Fine giornata: si guarda a domani
r = home(3, "In viaggio · sera", "Dopo l'ultima attività la scheda guarda a domani: la prima attività e l'orario. Le attività di oggi si chiudono in una riga.")
c = today(r)
next_block(c, "DOMANI · DOM 26 OTTOBRE", "Musei Vaticani alle 09:30", "4 attività · ultimo giorno", color=LAG, nav=False)
sumr = d.row(c, "Fatte", gap=10, H="fill")
dot = d.node("frame", sumr, "Pallino", w=22, h=22, fill=d.pos, cornerRadius=11, layout="horizontal", mainAlign="center", crossAlign="center")
d.icon(dot, "check", WHITE, 15)
d.text(sumr, "Oggi 5 attività su 5", FIG, "SemiBold", 15.5, d.on, fillw=True)
d.text(sumr, "mostra", BRI, "Bold", 14, d.accent)
actions(c)

# ---------- 5. Giorno senza orari
r = home(4, "In viaggio · senza orari", "Attività senza orario: niente «adesso» né conto alla rovescia. Il cerchio si tocca per segnarla fatta; in evidenza la prima da fare.")
c = today(r)
next_block(c, "DA FARE", "Pantheon", "Piazza della Rotonda · 2 attività ancora")
g = d.frame(c, "Giornata", gap=6)
for k, (ti, pl, s) in enumerate([("Fontana di Trevi", "Piazza di Trevi", "done"), ("Pantheon", "Piazza della Rotonda", "free"), ("Gelato da Giolitti", None, "free")]):
    step(g, None, None, ti, pl, s, last=k == 2, timed=False)
d.note(c, "Tocca il cerchio per segnare fatta un'attività.", size=13)
actions(c)

# ---------- 6. Giornata libera
r = home(5, "In viaggio · giornata libera", "Nessuna attività oggi: lo si dice, con un tasto per aggiungerne una. Sotto, lo sguardo a domani.")
c = today(r, "ven 24 ottobre · giorno 2 di 4")
b = d.frame(c, "Libera", gap=4, pad=[16, 16, 16, 16], fill=SOLE, cornerRadius=20)
d.text(b, "Giornata libera", BRI, "ExtraBold", 21, INK)
d.text(b, "Nessuna attività in programma.", FIG, "Medium", 13.5, INK, fillw=True)
nx = d.row(c, "Domani", gap=10, H="fill")
d.text(nx, "Domani", FIG, "SemiBold", 15.5, d.on)
d.text(nx, "09:00 Colazione al Gianicolo · 5 attività", FIG, "Regular", 14, d.muted, fillw=True)
r2 = d.row(c, "Scorciatoie", gap=8, H="fill")
a = d.frame(r2, "Attività", "horizontal", 6, [10, 16, 10, 12], d.cta_bg, H="hug", cornerRadius=22, crossAlign="center")
d.icon(a, "plus", SOLE if not d.dark else INK, 18)
d.text(a, "Attività", BRI, "Bold", 15, d.on_cta)
s = d.frame(r2, "Spesa", "horizontal", 6, [10, 16, 10, 12], SOLE, H="hug", cornerRadius=22, crossAlign="center")
d.icon(s, "plus", INK, 18)
d.text(s, "Spesa", BRI, "Bold", 15, INK)

# ---------- 7. Domani (scheda girata)
r = home(6, "In viaggio · domani", "«Domani» gira la scheda sul giorno dopo: stesse righe, niente «adesso». Torna su «Oggi» da sola quando si riapre la Home.")
c = today(r, "dom 26 ottobre · ultimo giorno", tab=1)
next_block(c, "LA PRIMA · ALLE 09:30", "Musei Vaticani", "Viale Vaticano · 4 attività in tutto", color=LAG)
g = d.frame(c, "Giornata", gap=6)
for k, it in enumerate([("09:30", "12:30", "Musei Vaticani", "Viale Vaticano"), ("13:00", None, "Pranzo in Prati", "Via Cola di Rienzo"), ("15:00", None, "Castel Sant'Angelo", "Lungotevere Castello 50"), ("19:40", None, "Treno per Milano", "Roma Termini")]):
    step(g, *it, "todo", last=k == 3)
actions(c)

if __name__ == "__main__":
    publish(d, "P In viaggio", "P · In viaggio")
