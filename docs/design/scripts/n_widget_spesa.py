# Pagina N: widget "Spesa rapida" e schermata per fissare una spesa in due passi.
from figcraft_kit import *

I["food"] = "M11 9H9V2H7v7H5V2H3v7c0 2.12 1.66 3.84 3.75 3.97V22h2.5v-9.03C11.34 12.84 13 11.12 13 9V2h-2v7zm5-3v8h2.5v8H21V2c-2.76 0-5 2.24-5 4z"
I["ticket"] = "M20 12c0-1.1.9-2 2-2V6c0-1.1-.9-2-2-2H4c-1.1 0-1.99.9-1.99 2v4c1.1 0 1.99.9 1.99 2s-.89 2-2 2v4c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2v-4c-1.1 0-2-.9-2-2zm-4.42 4.8L12 14.5l-3.58 2.3 1.08-4.12-3.29-2.69 4.24-.25L12 5.8l1.54 3.95 4.24.25-3.29 2.69 1.09 4.11z"
I["taxi"] = "M18.92 6.01C18.72 5.42 18.16 5 17.5 5H15V3H9v2H6.5c-.66 0-1.21.42-1.42 1.01L3 12v8c0 .55.45 1 1 1h1c.55 0 1-.45 1-1v-1h12v1c0 .55.45 1 1 1h1c.55 0 1-.45 1-1v-8l-2.08-5.99zM6.5 16c-.83 0-1.5-.67-1.5-1.5S5.67 13 6.5 13s1.5.67 1.5 1.5S7.33 16 6.5 16zm11 0c-.83 0-1.5-.67-1.5-1.5s.67-1.5 1.5-1.5 1.5.67 1.5 1.5-.67 1.5-1.5 1.5zM5 11l1.5-4.5h11L19 11H5z"
I["backspace"] = "M22 3H7c-.69 0-1.23.35-1.59.88L0 12l5.41 8.11c.36.53.9.89 1.59.89h15c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-3 12.59L17.59 17 14 13.41 10.41 17 9 15.59 12.59 12 9 8.41 10.41 7 14 10.59 17.59 7 19 8.41 15.41 12 19 15.59z"

d = Doc()
STEP = 452
# Le quattro categorie del widget; "Altro" apre l'elenco completo.
CATS = [("food", "Cibo", SOLE, INK), ("ticket", "Attività", FEN, INK), ("taxi", "Taxi", COB, WHITE), ("plus", "Altro", INK, WHITE)]

d.node("text", None, "Titolo pagina", x=0, y=-110, text="Spesa rapida", fontFamily=BRI, fontStyle="ExtraBold", fontSize=34, fill=INK)
d.node("text", None, "Flusso", x=0, y=-64, w=1300, text="Due passi: tocchi la categoria sul widget, scrivi l'importo e salvi. Pagante, divisione e data partono da quelli predefiniti e si cambiano con un tocco.", fontFamily=FIG, fontStyle="Regular", fontSize=16, fill=MUTED)

# ---------- Widget sulla Home
home = d.node("frame", None, "Home / Widget spesa", x=0, y=d.y0, w=412, h=917, fill="#0B0B12", clip=True, cornerRadius=28)
d.node("text", home, "Didascalia", x=20, y=24, text="Sulla Home", fontFamily=FIG, fontStyle="Medium", fontSize=13, fill="#9AA0C0")


def widget_large(parent, x, y, trip=True):
    w = d.node("frame", parent, "Widget 4×2", x=x, y=y, w=372, h=178, fill=LAG, cornerRadius=24, layout="vertical", gap=12, padding=16)
    top = d.row(w, "Testa", gap=8, H="fill", main="spaceBetween", cross="min")
    t = d.frame(top, "Testi", gap=0, H="fill")
    d.text(t, "Spesa rapida", FIG, "SemiBold", 13, INK)
    d.text(t, "Sardegna per il pupo" if trip else "Nessun viaggio in corso", BRI, "Bold", 17, INK, fillw=True)
    if trip:
        tot = d.frame(top, "Totale", gap=0, H="hug", crossAlign="max")
        d.text(tot, "€ 412", BRI, "ExtraBold", 26, INK)
        d.text(tot, "spesi", FIG, "Medium", 12, INK)
        row = d.row(w, "Categorie", gap=8, H="fill", main="spaceBetween")
        for key, label, bg, fg in CATS:
            b = d.frame(row, label, gap=6, H="fill", crossAlign="center")
            c = d.node("frame", b, "Cerchio", w=52, h=52, fill=bg, cornerRadius=26, layout="horizontal", mainAlign="center", crossAlign="center")
            d.icon(c, key, fg, 24)
            d.text(b, label, FIG, "SemiBold", 12, INK)
    else:
        d.text(w, "Le spese si fissano su un viaggio: creane uno per iniziare.", FIG, "Regular", 14, INK, fillw=True)
        d.node("frame", w, "Spazio", h=1, fill="none", sizingH="fill", sizingV="fill")
        nb = d.node("frame", w, "Nuovo viaggio", h=44, fill=INK, cornerRadius=22, layout="horizontal", mainAlign="center", crossAlign="center", gap=6, padding=[0, 18, 0, 18], sizingH="hug", sizingV="fixed")
        d.icon(nb, "plus", SOLE, 20)
        d.text(nb, "Nuovo viaggio", BRI, "Bold", 15, WHITE)
    return w


def widget_small(parent, x, y):
    w = d.node("frame", parent, "Widget 2×2", x=x, y=y, w=178, h=178, fill=LAG, cornerRadius=24, layout="vertical", gap=4, padding=16)
    d.text(w, "Sardegna per il pupo", BRI, "Bold", 15, INK, fillw=True, lh=18)
    d.text(w, "€ 412 spesi", FIG, "Medium", 13, INK)
    d.node("frame", w, "Spazio", h=1, fill="none", sizingH="fill", sizingV="fill")
    b = d.node("frame", w, "Spesa", h=48, fill=INK, cornerRadius=24, layout="horizontal", mainAlign="center", crossAlign="center", gap=6, sizingH="fill", sizingV="fixed")
    d.icon(b, "plus", SOLE, 20)
    d.text(b, "Spesa", BRI, "Bold", 16, WHITE)
    return w


widget_large(home, 20, 52)
d.node("text", home, "Didascalia", x=20, y=250, text="Piccolo: un solo tasto, poi si sceglie la categoria", fontFamily=FIG, fontStyle="Medium", fontSize=13, fill="#9AA0C0")
widget_small(home, 20, 278)
d.node("text", home, "Didascalia", x=20, y=478, text="Senza un viaggio in corso o in arrivo", fontFamily=FIG, fontStyle="Medium", fontSize=13, fill="#9AA0C0")
widget_large(home, 20, 506, trip=False)

# ---------- Passo 2: importo e salva
r = d.screen("Spesa rapida", STEP)
hd = d.frame(r, "Testata", gap=10, pad=[46, 20, 18, 20], fill=LAG, cornerRadius=[0, 0, 32, 32])
bar = d.row(hd, "Barra", main="spaceBetween", H="fill")
d.icon(bar, "close", INK, 24)
d.text(hd, "Spesa rapida", BRI, "ExtraBold", 30, INK)
trip = d.row(hd, "Viaggio", gap=6, pad=[7, 14, 7, 14], fill=WHITE, H="hug", cornerRadius=18)
d.text(trip, "Sardegna per il pupo", FIG, "SemiBold", 14, INK)
d.icon(trip, "down", INK, 20)
b = d.frame(r, "Contenuto", gap=14, pad=[16, 20, 20, 20], V="fill")
chips = d.row(b, "Categorie", gap=8, H="fill", clip=True)
d.chip(chips, "Cibo", True)
for s in ("Attività", "Taxi", "Biglietto", "Carburante"):
    d.chip(chips, s)
amt = d.frame(b, "Importo", gap=2, crossAlign="center")
d.text(amt, "€ 12,50", BRI, "ExtraBold", 60, d.on)
d.note(amt, "Cibo · oggi", fillw=False)
d.field(b, "Descrizione (facoltativa)", None, hint="Pranzo al porto")
opts = d.wrap(b, "Opzioni", 8)
for s in ("Pagata da Tu", "In parti uguali"):
    c = d.frame(opts, s, "horizontal", 4, [8, 10, 8, 14], d.card_bg, H="hug", cornerRadius=20, stroke=d.hair, strokeWeight=1, crossAlign="center")
    d.text(c, s, FIG, "SemiBold", 14, d.on)
    d.icon(c, "down", d.muted, 18)
keys = d.frame(b, "Tastierino", gap=8)
for rowkeys in (("1", "2", "3"), ("4", "5", "6"), ("7", "8", "9"), (",", "0", "⌫")):
    rw = d.frame(keys, "Riga", "horizontal", 8)
    for k in rowkeys:
        kk = d.node("frame", rw, k, h=58, fill=d.card_bg, cornerRadius=18, layout="horizontal", mainAlign="center", crossAlign="center", sizingH="fill", sizingV="fixed", stroke=d.hair, strokeWeight=1)
        if k == "⌫":
            d.icon(kk, "backspace", d.on, 24)
        else:
            d.text(kk, k, BRI, "Bold", 24, d.on)
d.cta(b, "Salva spesa")

# ---------- Conferma
r = d.screen("Spesa rapida / Salvata", STEP * 2)
c = d.frame(r, "Centro", gap=12, pad=[0, 32, 0, 32], V="fill", mainAlign="center", crossAlign="center")
ok = d.node("frame", c, "Spunta", w=120, h=120, fill=LAG, cornerRadius=60, layout="horizontal", mainAlign="center", crossAlign="center")
d.icon(ok, "check", INK, 60)
d.text(c, "Spesa salvata", BRI, "ExtraBold", 30, d.on)
d.text(c, "Cibo · € 12,50 · Sardegna per il pupo", FIG, "Medium", 15, d.muted, align="center", fillw=True)
d.text(c, "In questo viaggio hai speso € 424,50", FIG, "Regular", 15, d.on, align="center", fillw=True)
bb = d.frame(r, "Azioni", gap=10, pad=[0, 20, 28, 20])
d.cta(bb, "Fatto")
d.cta(bb, "Aggiungi un'altra", outlined=True)
und = d.row(bb, "Annulla", main="center", H="fill")
d.icon(und, "back", d.accent, 18)
d.text(und, "Annulla la spesa", BRI, "Bold", 15, d.accent)

# ---------- "Altro": tutte le categorie
s = d.sheet(STEP * 3, "Categoria", name="Spesa rapida / Altro")
w = d.wrap(s, "Tutte", 8)
for i, lab in enumerate(["Cibo", "Attività", "Taxi", "Biglietto", "Carburante", "Pedaggio", "Parcheggio", "Noleggio", "Bagaglio", "Assicurazione", "Alloggio", "Altro"]):
    d.chip(w, lab, i == 4, LAG)

# ---------- "Per quota": le quote si scelgono sulla singola spesa
QUOTE = [("Tu", 0.5, "12,50 €", COB, WHITE), ("Marco", 0.25, "6,25 €", SOLE, INK), ("Anna", 0.25, "6,25 €", FEN, INK)]


def quote_rows(parent):
    q = d.frame(parent, "Quote", gap=8)
    head = d.row(q, "Titolo quote", main="spaceBetween", H="fill")
    d.text(head, "Quote", BRI, "Bold", 17, d.on)
    d.note(head, "Totale 1 · 0 = escluso", size=13, fillw=False)
    for name, f, cents, bg, fg in QUOTE:
        c = d.frame(q, name, "vertical", 6, [10, 14, 12, 10], d.card_bg, stroke=d.hair, strokeWeight=1, cornerRadius=16)
        top = d.row(c, "Riga", gap=12, H="fill")
        d.avatar(top, name[0], bg, fg, 36)
        t = d.frame(top, "Testi", gap=0, H="fill")
        d.text(t, name, FIG, "SemiBold", 15, d.on)
        d.note(t, cents, size=13)
        active = name == "Tu"
        box = d.frame(top, "Campo quota", "horizontal", 0, [4, 10, 4, 10], d.card_bg, H="hug", cornerRadius=10,
                      stroke=LAG if active else d.hair, strokeWeight=2 if active else 1, crossAlign="center")
        d.text(box, f"{f:.2f}".replace(".", ","), BRI, "ExtraBold", 22, d.on)
        track = d.node("frame", c, "Cursore", h=20, fill="none", sizingH="fill", sizingV="fixed")
        d.node("frame", track, "Binario", x=0, y=8, w=364, h=4, fill=d.hair, cornerRadius=2)
        d.node("frame", track, "Attivo", x=0, y=8, w=int(364 * f), h=4, fill=LAG, cornerRadius=2)
        d.node("frame", track, "Pomello", x=int(364 * f) - 10, y=0, w=20, h=20, fill=LAG, cornerRadius=10, stroke=d.card_bg, strokeWeight=3)
    return q


r = d.screen("Spesa rapida / Per quota", STEP * 4, h=1300)
hd = d.frame(r, "Testata", gap=10, pad=[46, 20, 18, 20], fill=LAG, cornerRadius=[0, 0, 32, 32])
bar = d.row(hd, "Barra", H="fill")
d.icon(bar, "close", INK, 24)
d.text(hd, "Spesa rapida", BRI, "ExtraBold", 30, INK)
trip = d.row(hd, "Viaggio", gap=6, pad=[7, 14, 7, 14], fill=WHITE, H="hug", cornerRadius=18)
d.text(trip, "Sardegna per il pupo", FIG, "SemiBold", 14, INK)
d.icon(trip, "down", INK, 20)
b = d.frame(r, "Contenuto", gap=14, pad=[16, 20, 20, 20], V="fill")
amt = d.frame(b, "Importo", gap=2, crossAlign="center")
d.text(amt, "€ 25", BRI, "ExtraBold", 60, d.on)
d.note(amt, "Cibo · oggi", fillw=False)
opts = d.wrap(b, "Opzioni", 8)
for s, on in (("Pagata da Tu", False), ("Per quota", True)):
    c = d.frame(opts, s, "horizontal", 4, [8, 10, 8, 14], LAG if on else d.card_bg, H="hug", cornerRadius=20, **({} if on else {"stroke": d.hair, "strokeWeight": 1}), crossAlign="center")
    d.text(c, s, FIG, "SemiBold", 14, INK if on else d.on)
    d.icon(c, "down", INK if on else d.muted, 18)
quote_rows(b)
d.note(b, "Il numero si tocca e si scrive a mano (qui Tu, in modifica). Confermando, o spostando un cursore, il resto si divide tra gli altri: il totale resta sempre 1.", size=13)
keys = d.frame(b, "Tastierino (ridotto)", gap=8)
for rowkeys in (("1", "2", "3"), ("4", "5", "6"), ("7", "8", "9"), (",", "0", "⌫")):
    rw = d.frame(keys, "Riga", "horizontal", 8)
    for k in rowkeys:
        kk = d.node("frame", rw, k, h=58, fill=d.card_bg, cornerRadius=18, layout="horizontal", mainAlign="center", crossAlign="center", sizingH="fill", sizingV="fixed", stroke=d.hair, strokeWeight=1)
        if k == "⌫":
            d.icon(kk, "backspace", d.on, 24)
        else:
            d.text(kk, k, BRI, "Bold", 24, d.on)
d.cta(b, "Salva spesa")

# Foglio "Nuova spesa" del modulo: stesse quote sotto la divisione.
s = d.sheet(STEP * 5, "Nuova spesa", name="Nuova spesa / Per quota")
f2 = d.two(s)
d.field(f2, "Categoria", "Cibo")
d.field(f2, "Importo (€)", "25,00")
d.field(s, "Pagato da", "Tu")
d.text(s, "Divisione", FIG, "SemiBold", 15.5, d.on)
w = d.wrap(s, "Metodi", 8)
for lab in ("In parti uguali", "Per quota", "Non divisa"):
    d.chip(w, lab, lab == "Per quota", LAG)
quote_rows(s)
d.cta(s, "Salva")

publish(d, "N Widget spesa", "N · Widget spesa")
