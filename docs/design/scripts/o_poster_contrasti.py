# Pagina O, fila 3: i contrasti col buio. Con il cielo scuro (titolo bianco)
# nessun elemento deve confondersi: nuvole in un tono del cielo che lascia
# leggere il titolo, aereo e scia del Volo chiari, nuvole basse del Volo pervinca
# con le scritte bianche, luna del campeggio ritagliata a falce.
# Si aggiunge sotto le file 1-2 (o_poster_vivo.py) senza toccarle.
from figcraft_kit import *
from poster_kit import NOTTE, NUVOLA, PERVINCA, PIOMBO, Poster, cloud_on, mix

TAG = "· contrasti"
W, H = 372, 340
TOP = H - 240
GX = W + 48
Y3 = 1010


def dim(c, a):
    """Il velo inchiostro che scurisce la scena col buio (srcATop)."""
    return mix(c, INK, a)


d = Doc()
d.node("text", None, f"Titolo fila {TAG}", x=0, y=Y3, text="Contrasti col buio", fontFamily=BRI, fontStyle="ExtraBold", fontSize=30, fill=INK)
d.node("text", None, f"Nota fila {TAG}", x=0, y=Y3 + 40, w=1660, text="Quando il cielo è scuro (notte, sera, pioggia, temporale) il titolo diventa bianco, e niente deve confondersi con il cielo né con il titolo. Le nuvole stanno dalla parte del cielo: un tono del cielo schiarito verso il pervinca, mai bianche sotto un titolo bianco. L'aereo e la scia del Volo si schiariscono; le sue nuvole basse diventano pervinca e le scritte basse bianche. La luna del campeggio è una falce ritagliata.", fontFamily=FIG, fontStyle="Regular", fontSize=16, fill=MUTED)


def card(i, caption, note):
    x, y = GX * i, Y3 + 170
    d.node("text", None, f"Didascalia {TAG}", x=x, y=y - 54, text=caption, fontFamily=BRI, fontStyle="Bold", fontSize=18, fill=INK)
    d.node("text", None, f"Nota {TAG}", x=x, y=y - 28, w=W, text=note, fontFamily=FIG, fontStyle="Regular", fontSize=13, fill=MUTED)
    return Poster(d, d.node("frame", None, f"{caption} {TAG}", x=x, y=y, w=W, h=H, fill="none", clip=True, cornerRadius=24))


p = card(0, "Volo · notte", "Aereo nuvola, scia pervinca, nuvole basse pervinca: le scritte basse diventano bianche come sugli altri poster.")
p.sky(NOTTE)
p.stars(22, y_max=150)
p.flight(plane=NUVOLA, trail=PERVINCA, clouds=dim(PERVINCA, 0.38), moon_sky=NOTTE)
p.texts("Tokyo", "Tokyo, Giappone", "giorno 3 di 9", WHITE, WHITE, "moon", "12°")

sky = PIOMBO
p = card(1, "Volo · pioggia", "Basta il cielo scuro, anche di giorno. Le nuvole sono un tono del cielo: il titolo bianco resta leggibile anche sopra.")
p.sky(sky)
p.cloud(200, TOP + 10, 1.3, cloud_on(sky))
p.cloud(20, TOP - 40, 0.85, cloud_on(sky))
p.flight(plane=NUVOLA, trail=PERVINCA, clouds=dim(PERVINCA, 0.14))
p.rain(40)
p.texts("Weekend lungo a New York", "New York, Stati Uniti", "tra 2 giorni", WHITE, WHITE, "drop", "9°")

p = card(2, "Zaino · notte", "La luna è una falce ritagliata e resta gialla, fuori dal velo della notte: niente disco blu sul cielo scuro.")
p.sky(NOTTE)
p.stars(14, y_max=120)
p.camp(moon=SOLE, ground=dim(LAG, 0.38), tent=dim(FEN, 0.38), door=INK)
p.texts("Cammino di Santiago", "Santiago de Compostela", "giorno 5 di 12", WHITE, WHITE, "moon", "11°")

sky = mix(COB, PIOMBO, 0.3)
p = card(3, "Mare · nuvoloso", "Prima le nuvole erano bianche sotto un titolo bianco. Ora, sui cieli scuri, sono cielo schiarito verso il pervinca.")
p.sky(sky)
p.cloud(200, TOP - 40, 1.25, cloud_on(sky))
p.cloud(30, TOP - 84, 0.9, cloud_on(sky))
p.cloud(120, TOP - 6, 0.8, cloud_on(sky))
p.sea(sun=False, boat=True, waves=(dim(LAG, 0.14), dim(COBD, 0.14)))
p.texts("Sardegna per il pupo", "Cagliari, Italia", "giorno 2 di 6", WHITE, WHITE, "cloud", "21°")

append(d, "O Contrasti col buio", "O · Poster vivo", TAG)
