# Pagina O: il poster vivo. Il cielo segue l'ora della destinazione e il meteo
# vero (Open-Meteo): alba e tramonto, notte con luna e stelle, nuvole, pioggia,
# neve. La scena del tipo di viaggio resta: e' l'identita' del poster.
# Il movimento e' nella pagina K (k_poster_vivo.py).
from figcraft_kit import *
from poster_kit import NOTTE, NUVOLA, NUVOLA_NOTTE, NUVOLA_SCURA, PERVINCA, PIOMBO, Poster

W, H = 372, 340
TOP = H - 240

d = Doc()

d.node("text", None, "Titolo pagina", x=0, y=-150, text="Poster vivo", fontFamily=BRI, fontStyle="ExtraBold", fontSize=34, fill=INK)
d.node("text", None, "Flusso", x=0, y=-104, w=1560, text="Il cielo segue l'ora della destinazione e il meteo vero: alba e tramonto, notte con luna e stelle, nuvole che passano, pioggia e neve che cadono. La scena del tipo di viaggio resta sempre: è l'identità del poster. Senza rete o senza coordinate resta il poster di sempre, con l'ora del giorno calcolata sul posto.", fontFamily=FIG, fontStyle="Regular", fontSize=16, fill=MUTED)


def card(x, y, caption, note):
    d.node("text", None, "Didascalia", x=x, y=y - 54, text=caption, fontFamily=BRI, fontStyle="Bold", fontSize=18, fill=INK)
    d.node("text", None, "Nota", x=x, y=y - 28, w=W, text=note, fontFamily=FIG, fontStyle="Regular", fontSize=13, fill=MUTED)
    return Poster(d, d.node("frame", None, caption, x=x, y=y, w=W, h=H, fill="none", clip=True, cornerRadius=24))


GX = W + 48
ROW2 = H + 130

p = card(0, 0, "Mare · giorno, sereno", "Il colore del tipo di viaggio. Il mare deriva come oggi.")
p.sky(COB)
p.sea()
p.texts("Sardegna per il pupo", "Cagliari, Italia", "in corso", WHITE, WHITE, "sun", "27°")

p = card(GX, 0, "Mare · tramonto", "Un'ora prima e dopo il tramonto (e all'alba): bande calde e sole basso, grande.")
p.sky_bands(COB, FEN, 70, TOP + 118)
p.sea(sun_xy=(250, 120), sun_r=64)
p.texts("Sardegna per il pupo", "Cagliari, Italia", "in corso", WHITE, WHITE, "sun", "24°")

p = card(GX * 2, 0, "Mare · notte", "Dopo il tramonto: luna e stelle che brillano piano. Niente barca.")
p.sky(NOTTE)
p.stars(26)
p.moon(290, TOP + 60, 34, NOTTE)
p.sea(sun=False, boat=False, waves=("#0F7F86", "#0A1E78"))
p.texts("Sardegna per il pupo", "Cagliari, Italia", "in corso", WHITE, WHITE, "moon", "19°")

p = card(0, ROW2, "Mare · pioggia", "Cielo piombo, nuvole che passano lente, gocce che cadono in obliquo.")
p.sky(PIOMBO)
p.cloud(200, TOP + 10, 1.3, NUVOLA_SCURA)
p.cloud(60, TOP + 30, 0.8, NUVOLA_SCURA)
p.sea(sun=False, waves=("#0F9CA4", "#0A2590"))
p.rain(46)
p.texts("Sardegna per il pupo", "Cagliari, Italia", "in corso", WHITE, WHITE, "drop", "16°")

p = card(GX, ROW2, "Montagna · neve", "Cielo pervinca e fiocchi che ondeggiano scendendo; il prato si imbianca.")
p.sky(PERVINCA)
p.cloud(170, TOP - 70, 1.1, NUVOLA)
p.mountain(ground="#DDE4F7")
p.snow(48)
p.texts("Dolomiti", "Cortina d'Ampezzo, Italia", "tra 3 giorni", INK, INK, "snow", "-2°")

p = card(GX * 2, ROW2, "Città · notte, nuvoloso", "Le finestre si accendono; le nuvole scure velano la luna.")
p.sky(NOTTE)
p.stars(12, y_max=90)
p.moon(300, TOP - 20, 30, NOTTE)
p.cloud(230, TOP - 34, 1.0, NUVOLA_NOTTE)
p.cloud(40, TOP - 6, 0.8, NUVOLA_NOTTE)
p.city(NOTTE)
p.texts("Lisbona", "Lisbona, Portogallo", "domani", WHITE, WHITE, "cloud", "14°")

# ---------- Testata del viaggio: il meteo nelle pillole
X4 = GX * 3 + 40
r = d.screen("Viaggio / Meteo", X4, h=620)
hdr = Poster(d, d.node("frame", r, "Poster", w=412, h=380, fill=COB, clip=True), w=412, h=380)
hdr.sky_bands(COB, FEN, 70, hdr.Y(118))
hdr.sea(sun_xy=(250, 120), sun_r=64)
d.node("text", hdr.p, "Titolo", x=20, y=86, w=330, text="Sardegna per il pupo", fontFamily=BRI, fontStyle="ExtraBold", fontSize=43, lineHeight=44, fill=WHITE)
d.node("text", hdr.p, "Luogo", x=20, y=340, text="Cagliari, Italia", fontFamily=FIG, fontStyle="SemiBold", fontSize=14, fill=WHITE)
d.icon(hdr.p, "back", WHITE, 24, x=16, y=52)
b = d.frame(r, "Contenuto", gap=12, pad=[18, 20, 20, 20])
facts = d.row(b, "Pillole", gap=8, H="fill")
pl = d.frame(facts, "Stato", "horizontal", 0, [7, 16, 7, 16], SOLE, H="hug", cornerRadius=20)
d.text(pl, "in corso", BRI, "Bold", 15, INK)
pl = d.frame(facts, "Meteo", "horizontal", 6, [6, 14, 6, 10], "none", H="hug", cornerRadius=20, stroke=d.on, strokeWeight=1.5, crossAlign="center")
d.icon(pl, "sun", d.on, 18)
d.text(pl, "24° · sereno", BRI, "Bold", 15, d.on)
pl = d.frame(facts, "Persone", "horizontal", 0, [7, 16, 7, 16], "none", H="hug", cornerRadius=20, stroke=d.on, strokeWeight=1.5)
d.text(pl, "3 persone", BRI, "Bold", 15, d.on)
d.note(b, "A Cagliari sono le 19:42 · tramonto alle 20:01 · domani pioggia, 18°", size=14)

# ---------- Impostazioni: si puo' spegnere
r = d.screen("Impostazioni / Meteo", X4, y=d.y0 + 660, h=300)
b = d.frame(r, "Contenuto", gap=10, pad=[24, 20, 20, 20])
d.h2(b, "Aspetto")
row = d.card(b, "Riga meteo", crossAlign="center")
t = d.frame(row, "Testi", gap=2, H="fill")
d.text(t, "Meteo sul poster", FIG, "SemiBold", 16, d.on)
d.note(t, "Il cielo del poster segue il meteo della destinazione (Open-Meteo, solo con la rete).", size=13)
d.switch(row, True)
d.note(b, "Spento: resta solo l'ora del giorno, che si calcola senza rete. Con «Riduci animazioni» pioggia e neve restano ferme.", size=13)

d.node("text", None, "Movimento", x=0, y=ROW2 + H + 40, w=1180, text="Il movimento (cielo che cambia, meteo che arriva, pioggia, neve, nuvole, stelle) è nella pagina K, file 8 e 9.", fontFamily=FIG, fontStyle="Regular", fontSize=14, fill=MUTED)

publish(d, "O Poster vivo", "O · Poster vivo")
