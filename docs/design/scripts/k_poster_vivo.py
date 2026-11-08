# Pagina K, file 8 e 9: il movimento del poster vivo (cielo che segue l'ora,
# meteo che arriva, pioggia, neve). Si aggiunge in fondo alla pagina K senza
# toccare le file 1-7 (il loro script e' andato perso): vedi append().
from figcraft_kit import *
from poster_kit import NOTTE, NUVOLA, NUVOLA_SCURA, PERVINCA, PIOMBO, SERA, Poster, mix

TAG = "· poster vivo"
STEP = 452
Y8 = 9432   # le file 1-7 finiscono poco sotto y = 9160
Y9 = Y8 + 1300
ANN = SOLE  # frecce e tracce del movimento

d = Doc()


def row_title(y, title, note):
    d.node("text", None, f"Titolo fila {TAG}", x=0, y=y, text=title, fontFamily=BRI, fontStyle="ExtraBold", fontSize=30, fill=INK)
    d.node("text", None, f"Nota fila {TAG}", x=0, y=y + 38, w=1700, text=note, fontFamily=FIG, fontStyle="Regular", fontSize=16, fill=MUTED)


def screen(name, i, y, caption):
    """Schermata della Home col poster grande e la scheda dei tempi sotto."""
    r = d.node("frame", None, f"{name} {TAG}", x=STEP * i, y=y + 68, w=412, h=917, fill=CARTA, clip=True, cornerRadius=28)
    d.node("text", r, "Sezione", x=20, y=24, text="In arrivo", fontFamily=BRI, fontStyle="Bold", fontSize=20, fill=INK)
    card = d.node("frame", r, "Poster", x=20, y=60, w=372, h=340, fill="none", clip=True, cornerRadius=24)
    d.node("text", None, f"Didascalia {TAG}", x=STEP * i, y=y + 68 + 925, w=412, text=caption, fontFamily=FIG, fontStyle="Regular", fontSize=13, fill=MUTED)
    return r, Poster(d, card)


def spec(r, title, lines):
    c = d.node("frame", r, "Tempi", x=20, y=424, w=372, fill=WHITE, cornerRadius=20, layout="vertical", gap=8, padding=[16, 18, 18, 18], sizingV="hug", stroke=HAIR, strokeWeight=1)
    d.text(c, title, BRI, "Bold", 17, INK)
    for k, v in lines:
        row = d.row(c, "Riga", gap=10, H="fill", cross="min")
        d.text(row, k, FIG, "SemiBold", 14, INK, w=104)
        d.text(row, v, FIG, "Regular", 14, MUTED, fillw=True)


def arrow(p, pts, color=ANN, w=2.5):
    """Freccia del movimento lungo i punti dati (punta sull'ultimo)."""
    (x0, y0) = pts[0]
    path = f"M{x0} {y0} " + " ".join(f"L{x} {y}" for x, y in pts[1:])
    p.vec("Traccia", path, fill="none", stroke=color, strokeWeight=w, strokeCap="round", strokeJoin="round")
    (xa, ya), (xb, yb) = pts[-2], pts[-1]
    import math
    a = math.atan2(yb - ya, xb - xa)
    l = 10
    h1 = (xb - l * math.cos(a - 0.5), yb - l * math.sin(a - 0.5))
    h2 = (xb - l * math.cos(a + 0.5), yb - l * math.sin(a + 0.5))
    p.vec("Punta", f"M{h1[0]:.1f} {h1[1]:.1f} L{xb} {yb} L{h2[0]:.1f} {h2[1]:.1f}", fill="none", stroke=color, strokeWeight=w, strokeCap="round", strokeJoin="round")


def dots(p, pts, color=ANN, r=2.2):
    for x, y in pts:
        p.circle(x, y, r, color, "Traccia")


def label(p, x, y, s, color=INK, bg=ANN):
    t = d.frame(p.p, "Etichetta", "horizontal", 0, [3, 8, 3, 8], bg, H="hug", cornerRadius=10)
    d.node("text", t, "Testo", text=s, fontFamily=BRI, fontStyle="Bold", fontSize=13, fill=color)
    d.cmds[-2]["params"]["x"], d.cmds[-2]["params"]["y"] = x, y  # posizione del frame etichetta
    return t


T = 100  # cima della scena nel poster 372 x 340

# ===================== 8 · Il cielo segue l'ora =====================
row_title(Y8, "8 · Il cielo segue l'ora", "Il cielo cambia da solo con l'ora della destinazione: niente animazione all'apertura, il sole si sposta un poco ogni minuto e i passaggi sfumano lenti. Si vede la differenza tornando sull'app dopo un po'.")

r, p = screen("Ora / Pomeriggio", 0, Y8, "17:30 · il sole scende verso l'orizzonte seguendo l'arco (si sposta ogni minuto, mai a scatti).")
p.sky(COB)
p.sea(sun_xy=(290, 70))
dots(p, [(250, T + 92), (220, T + 104), (192, T + 112)], "#FFFFFFAA")
p.texts("Sardegna per il pupo", "Cagliari, Italia", "in corso", WHITE, WHITE, "sun", "27°")
spec(r, "Il sole", [("Posizione", "dall'ora locale, tra alba e tramonto"), ("Aggiornamento", "ogni minuto, spostamento di 240 ms"), ("All'apertura", "già al suo posto, nessun salto")])

r, p = screen("Ora / Tramonto", 1, Y8, "Un'ora attorno al tramonto: le bande calde salgono dall'orizzonte, il sole si fa grande e tocca il mare.")
p.sky_bands(COB, FEN, 70, T + 118)
p.sea(sun_xy=(250, 120), sun_r=64)
arrow(p, [(350, T + 96), (350, T + 20)], WHITE)
label(p, 286, T + 12, "60 min", INK, WHITE)
p.texts("Sardegna per il pupo", "Cagliari, Italia", "in corso", WHITE, WHITE, "sun", "24°")
spec(r, "Alba e tramonto", [("Quando", "da 1 ora prima a 1 ora dopo"), ("Bande", "il caldo sale e scende col sole"), ("Orari", "dal meteo, o calcolati sul posto")])

r, p = screen("Ora / Sera", 2, Y8, "Dopo il tramonto il cielo scurisce in circa 40 minuti e le stelle compaiono una alla volta.")
p.sky_bands(SERA, mix(SERA, FEN, 0.55), 40, T + 118, n=6)
p.stars(10, y_max=120, opacity=0.5)
p.moon(300, T + 10, 22, mix(SERA, mix(SERA, FEN, 0.55), 0.5), opacity=0.7)
p.sea(sun=False, waves=(mix(LAG, SERA, 0.35), mix(COBD, SERA, 0.3)))
p.texts("Sardegna per il pupo", "Cagliari, Italia", "in corso", WHITE, WHITE, "moon", "21°")
spec(r, "La sera", [("Durata", "40 minuti dopo il tramonto"), ("Stelle", "si accendono una alla volta"), ("Scritte", "da inchiostro a bianco, in dissolvenza")])

r, p = screen("Ora / Notte", 3, Y8, "Notte: le stelle luccicano piano e sfasate, la luna resta ferma, niente barca.")
p.sky(NOTTE)
p.stars(26)
for x, y in ((70, 46), (200, 80), (330, 30)):
    p.circle(x, y, 7, "#FFFFFF33", "Luccichio")
    p.circle(x, y, 2.5, WHITE, "Stella")
p.moon(290, T + 60, 34, NOTTE)
p.sea(sun=False, boat=False, waves=("#0F7F86", "#0A1E78"))
p.texts("Sardegna per il pupo", "Cagliari, Italia", "in corso", WHITE, WHITE, "moon", "19°")
spec(r, "La notte", [("Stelle", "luccichio di 2-4 s, ognuna col suo ritmo"), ("Luna", "ferma; fase non disegnata"), ("Città", "le finestre si accendono")])

# ===================== 9 · Il meteo sul poster =====================
row_title(Y9, "9 · Il meteo sul poster", "Quando arriva il meteo il cielo sfuma in 900 ms e la pillola compare. Pioggia, neve e nuvole si muovono solo sul poster in vista (Home e testata), mai negli elenchi; con «Riduci animazioni» restano ferme.")

r, p = screen("Meteo / Apertura", 0, Y9, "All'apertura: il poster di sempre e la pillola in attesa, mentre il meteo arriva (dalla memoria, se è recente).")
p.sky(COB)
p.sea()
p.texts("Sardegna per il pupo", "Cagliari, Italia", "in corso", WHITE, WHITE, "cloud", "—", chip_opacity=0.45)
spec(r, "Il meteo", [("Da dove", "Open-Meteo, per le coordinate della destinazione"), ("Memoria", "30 minuti; senza rete l'ultimo noto"), ("Senza", "poster di sempre, nessun errore")])

r, p = screen("Meteo / Arriva", 1, Y9, "Arriva la pioggia: il cielo sfuma verso il piombo e le nuvole entrano da destra.")
p.sky(mix(COB, PIOMBO, 0.55))
p.cloud(300, T + 6, 1.3, NUVOLA_SCURA)
p.sea(waves=("#0F9CA4", "#0A2590"))
arrow(p, [(362, T + 22), (282, T + 22)])
label(p, 290, T + 30, "900 ms")
p.texts("Sardegna per il pupo", "Cagliari, Italia", "in corso", WHITE, WHITE, "drop", "16°", chip_opacity=0.7)
spec(r, "Il passaggio", [("Cielo", "dissolvenza 900 ms, curva morbida"), ("Nuvole", "entrano da destra, poi derivano in 40 s"), ("Pillola", "scatta come le spunte (Motion.pop)")])

r, p = screen("Meteo / Pioggia", 2, Y9, "Pioggia: gocce oblique che cadono senza fine; ognuna attraversa il poster in 0,9 s.")
p.sky(PIOMBO)
p.cloud(200, T + 10, 1.3, NUVOLA_SCURA)
p.cloud(60, T + 30, 0.8, NUVOLA_SCURA)
p.sea(sun=False, waves=("#0F9CA4", "#0A2590"))
p.rain(40)
arrow(p, [(180, T + 20), (156, T + 80)], ANN, 3)
label(p, 184, T + 40, "0,9 s")
p.texts("Sardegna per il pupo", "Cagliari, Italia", "in corso", WHITE, WHITE, "drop", "16°")
spec(r, "La pioggia", [("Gocce", "40-60, oblique, lunghezze diverse"), ("Ciclo", "0,9 s per attraversare, sfasate"), ("Temporale", "più gocce e un lampo raro, giallo")])

r, p = screen("Meteo / Neve", 3, Y9, "Neve: i fiocchi scendono in 7 s ondeggiando, i più grandi davanti e più veloci.")
p.sky(PERVINCA)
p.cloud(170, T - 70, 1.1, NUVOLA)
p.mountain(ground="#DDE4F7")
p.snow(40)
pts = [(60 + 14 * ((i % 2) * 2 - 1), T - 10 + i * 24) for i in range(6)]
arrow(p, pts, ANN, 2.5)
label(p, 88, T - 4, "7 s")
p.texts("Dolomiti", "Cortina d'Ampezzo, Italia", "tra 3 giorni", INK, INK, "snow", "-2°")
spec(r, "La neve", [("Fiocchi", "40-60, tre grandezze"), ("Ciclo", "7 s di caduta, ondeggio di 2 s"), ("Profondità", "i grandi davanti e più veloci")])

r, p = screen("Meteo / Riduci animazioni", 4, Y9, "Con «Riduci animazioni»: cielo e meteo restano, disegnati fermi. Nessun movimento.")
p.sky(PIOMBO)
p.cloud(200, T + 10, 1.3, NUVOLA_SCURA)
p.sea(sun=False, waves=("#0F9CA4", "#0A2590"))
p.rain(40)
p.texts("Sardegna per il pupo", "Cagliari, Italia", "in corso", WHITE, WHITE, "drop", "16°")
spec(r, "Fermo", [("Cielo", "cambia di colpo, senza dissolvenza"), ("Pioggia e neve", "disegnate ferme"), ("Elenchi", "sempre fermi, anche senza l'opzione")])

append(d, "K Poster vivo", "K · Movimento", TAG)
