# Disegni del poster vivo condivisi dalle pagine O e K: cieli del meteo, scene
# (stesse coordinate di PosterPainter, 372 x 240 ancorate in basso), nuvole,
# stelle, luna, pioggia e neve.
import random

from city import city_cmds
from figcraft_kit import BRI, COB, COBD, FEN, FIG, I, INK, LAG, SOLE, WHITE

I["sun"] = "M6.76 4.84l-1.8-1.79-1.41 1.41 1.79 1.79 1.42-1.41zM4 10.5H1v2h3v-2zm9-9.95h-2V3.5h2V.55zm7.45 3.91l-1.41-1.41-1.79 1.79 1.41 1.41 1.79-1.79zm-3.21 13.7l1.79 1.8 1.41-1.41-1.8-1.79-1.4 1.4zM20 10.5v2h3v-2h-3zm-8-5c-3.31 0-6 2.69-6 6s2.69 6 6 6 6-2.69 6-6-2.69-6-6-6zm-1 16.95h2V19.5h-2v2.95zm-7.45-3.91l1.41 1.41 1.79-1.8-1.41-1.41-1.79 1.8z"
I["cloud"] = "M19.35 10.04C18.67 6.59 15.64 4 12 4 9.11 4 6.6 5.64 5.35 8.04 2.34 8.36 0 10.91 0 14c0 3.31 2.69 6 6 6h13c2.76 0 5-2.24 5-5 0-2.64-2.05-4.78-4.65-4.96z"
I["drop"] = "M12 2c-5.33 4.55-8 8.48-8 11.8 0 4.98 3.8 8.2 8 8.2s8-3.22 8-8.2c0-3.32-2.67-7.25-8-11.8z"
I["snow"] = "M22 11h-4.17l3.24-3.24-1.41-1.42L15 11h-2V9l4.66-4.66-1.42-1.41L13 6.17V2h-2v4.17L7.76 2.93 6.34 4.34 11 9v2H9L4.34 6.34 2.93 7.76 6.17 11H2v2h4.17l-3.24 3.24 1.41 1.42L9 13h2v2l-4.66 4.66 1.42 1.41L11 17.83V22h2v-4.17l3.24 3.24 1.42-1.41L13 15v-2h2l4.66 4.66 1.41-1.42L17.83 13H22z"

# Cieli del meteo (stessa famiglia di Cartolina).
NOTTE = INK
SERA = "#2A2F7A"
PIOMBO = "#46508A"
PERVINCA = "#8E9BD6"
NUVOLA = "#E9ECF8"


def mix(a, b, t):
    a, b = int(a[1:7], 16), int(b[1:7], 16)
    ch = [round(((a >> s) & 255) * (1 - t) + ((b >> s) & 255) * t) for s in (16, 8, 0)]
    return "#%02X%02X%02X" % tuple(ch)


def lum(h):
    """Luminanza relativa (come Color.computeLuminance)."""
    def f(c):
        c /= 255
        return c / 12.92 if c <= 0.03928 else ((c + 0.055) / 1.055) ** 2.4
    v = int(h[1:7], 16)
    return 0.2126 * f(v >> 16) + 0.7152 * f((v >> 8) & 255) + 0.0722 * f(v & 255)


def dark_sky(sky):
    """Cielo scuro = titolo bianco (stessa soglia di PosterSky.colorsFor)."""
    return lum(sky) < 0.3


def cloud_on(sky):
    """Le nuvole stanno dalla parte del cielo: sui cieli scuri un tono del cielo
    verso il pervinca, che non toglie leggibilita' al titolo bianco; sui cieli
    chiari nuvola."""
    if not dark_sky(sky):
        return NUVOLA
    c = mix(sky, PERVINCA, 0.45)
    return c if lum(c) <= 0.2 else mix(sky, PIOMBO, 0.55)


# Le nuvole della pioggia (cielo piombo) e della notte.
NUVOLA_SCURA = cloud_on(PIOMBO)
NUVOLA_NOTTE = cloud_on(NOTTE)


class Poster:
    """Disegna dentro un contenitore largo W e alto H (scena scalata di K)."""

    def __init__(self, d, parent, w=372, h=340, seed=7):
        self.d, self.p = d, parent
        self.W, self.H = w, h
        self.K = w / 372
        self.TOP = h - 240 * self.K
        self.rnd = random.Random(seed)

    def X(self, v):
        return round(v * self.K, 2)

    def Y(self, v):
        return round(self.TOP + v * self.K, 2)

    # --- primitive ---------------------------------------------------------
    def circle(self, cx, cy, r, fill, name="Cerchio", parent=None, **kw):
        return self.d.node("frame", parent or self.p, name, x=round(cx - r, 2), y=round(cy - r, 2), w=round(2 * r, 2), h=round(2 * r, 2), fill=fill, cornerRadius=r, **kw)

    def vec(self, name, path, parent=None, **props):
        # Le coordinate del path sono gia' quelle del contenitore.
        return self.d.node("vector", parent or self.p, name, x=0, y=0, path=path, **props)

    def sky(self, color):
        self.d.node("frame", self.p, "Cielo", x=0, y=0, w=self.W, h=self.H, fill=color)

    def sky_bands(self, top, bottom, y0, y1, n=7):
        """Sfumatura a bande piatte, come una stampa a pochi colori."""
        self.d.node("frame", self.p, "Cielo", x=0, y=0, w=self.W, h=y0 + 1, fill=top)
        step = (y1 - y0) / n
        for i in range(n):
            self.d.node("frame", self.p, "Banda", x=0, y=round(y0 + i * step), w=self.W, h=round(step) + 1, fill=mix(top, bottom, (i + 1) / n))
        self.d.node("frame", self.p, "Banda", x=0, y=y1, w=self.W, h=self.H - y1, fill=bottom)

    def cloud(self, x, y, k, fill, **kw):
        """Nuvola piatta: base arrotondata e tre gobbe."""
        g = self.d.node("frame", self.p, "Nuvola", x=x, y=y, w=round(120 * k), h=round(56 * k), fill="none", **kw)
        self.d.node("frame", g, "Base", x=0, y=round(28 * k), w=round(120 * k), h=round(28 * k), fill=fill, cornerRadius=round(14 * k))
        for cx, cy, r in ((34, 30, 20), (64, 22, 26), (94, 32, 18)):
            self.circle(cx * k, cy * k, r * k, fill, "Gobba", parent=g)
        return g

    def stars(self, n, y_max=150, color="#FFFFFF", opacity=1):
        for _ in range(n):
            r = self.rnd.choice((1.5, 2, 2.5))
            self.circle(self.rnd.randint(16, self.W - 16), self.rnd.randint(16, y_max), r, color, "Stella", opacity=opacity)

    def moon(self, cx, cy, r, sky, opacity=1):
        self.circle(cx, cy, r, "#FFF6D8", "Luna", opacity=opacity)
        self.circle(cx + r * 0.45, cy - r * 0.3, r * 0.9, sky, "Ombra luna")

    def rain(self, n, color="#FFFFFFAA", length=18, opacity=1):
        segs = []
        for _ in range(n):
            x, y = self.rnd.randint(0, self.W + 40), self.rnd.randint(0, self.H - 30)
            segs.append(f"M{x} {y} L{x - length * 0.4:.1f} {y + length}")
        self.vec("Pioggia", " ".join(segs), fill="none", stroke=color, strokeWeight=2.2, strokeCap="round", opacity=opacity)

    def snow(self, n, color="#FFFFFF"):
        for _ in range(n):
            self.circle(self.rnd.randint(6, self.W - 6), self.rnd.randint(6, self.H - 6), self.rnd.choice((2.5, 3, 4)), color, "Fiocco")

    # --- scene ---------------------------------------------------------------
    def sea(self, sun=True, sun_xy=(290, 100), sun_r=54, sun_color=SOLE, boat=True, waves=(LAG, COBD)):
        X, Y = self.X, self.Y
        if sun:
            self.circle(X(sun_xy[0]), Y(sun_xy[1]), sun_r * self.K, sun_color, "Sole")
        if boat:
            self.vec("Vela", f"M{X(74)} {Y(44)} L{X(74)} {Y(80)} L{X(112)} {Y(80)} Z", fill=WHITE)
            self.vec("Scafo", f"M{X(48)} {Y(86)} L{X(114)} {Y(86)} L{X(102)} {Y(104)} L{X(60)} {Y(104)} Z", fill=FEN)
        self.vec("Onda", f"M0 {Y(110)} C{X(60)} {Y(88)} {X(124)} {Y(88)} {X(186)} {Y(110)} C{X(248)} {Y(132)} {X(312)} {Y(132)} {X(372)} {Y(110)} L{X(372)} {Y(240)} L0 {Y(240)} Z", fill=waves[0])
        self.vec("Onda bassa", f"M0 {Y(146)} C{X(90)} {Y(134)} {X(120)} {Y(158)} {X(186)} {Y(146)} C{X(252)} {Y(134)} {X(300)} {Y(134)} {X(372)} {Y(146)} L{X(372)} {Y(240)} L0 {Y(240)} Z", fill=waves[1])

    def mountain(self, ground=LAG):
        X, Y = self.X, self.Y
        self.vec("Monti", f"M0 {Y(240)} L{X(130)} {Y(54)} L{X(198)} {Y(140)} L{X(262)} {Y(28)} L{X(372)} {Y(240)} Z", fill=COB)
        self.vec("Neve vetta", f"M{X(262)} {Y(28)} L{X(290)} {Y(82)} L{X(268)} {Y(72)} L{X(252)} {Y(88)} L{X(236)} {Y(74)} Z", fill=WHITE)
        self.vec("Neve vetta 2", f"M{X(130)} {Y(54)} L{X(150)} {Y(82)} L{X(136)} {Y(76)} L{X(124)} {Y(88)} L{X(112)} {Y(80)} Z", fill=WHITE)
        self.vec("Prato", f"M0 {Y(148)} C{X(100)} {Y(112)} {X(220)} {Y(176)} {X(372)} {Y(138)} L{X(372)} {Y(240)} L0 {Y(240)} Z", fill=ground)

    def city(self, sky, windows=SOLE, back="#2A3FA8", front="#16247A"):
        for cmd in city_cmds({"$ref": self.p}, 0, self.TOP, self.K, sky, back, front, windows):
            self.d.n += 1
            self.d.cmds.append(cmd)

    # --- scritte del poster grande della Home ---------------------------------
    def texts(self, title, place, pill, fg, lower, chip_icon=None, chip_text=None, packing="valigia 12/30", chip_opacity=1):
        d, W, H = self.d, self.W, self.H
        d.node("text", self.p, "Titolo", x=22, y=18, w=W - 72, text=title, fontFamily=BRI, fontStyle="ExtraBold", fontSize=round(W * 0.12), lineHeight=round(W * 0.122), fill=fg)
        d.node("text", self.p, "Luogo", x=22, y=H - 84, text=place, fontFamily=FIG, fontStyle="SemiBold", fontSize=14, fill=lower)
        row = d.node("frame", self.p, "Riga bassa", x=22, y=H - 58, w=W - 44, h=38, fill="none", layout="horizontal", gap=12, crossAlign="center")
        p = d.frame(row, "Pillola", "horizontal", 0, [8, 16, 8, 16], SOLE, H="hug", cornerRadius=20)
        d.text(p, pill, BRI, "Bold", 15, INK)
        d.text(row, packing, FIG, "Medium", 14, lower, fillw=True)
        if chip_icon:
            chip = d.frame(row, "Meteo", "horizontal", 5, [6, 12, 6, 9], "#FFFFFF2E" if lower == WHITE else "#11153A1F", H="hug", cornerRadius=18, crossAlign="center", opacity=chip_opacity)
            d.icon(chip, chip_icon, lower, 18)
            d.text(chip, chip_text, BRI, "Bold", 15, lower)


# --- scene aggiunte per i contrasti di notte (Volo e Zaino) -------------------
import math as _m


def _poly(pts):
    return "M" + " L".join(f"{x:.2f} {y:.2f}" for x, y in pts) + " Z"


def _plane_parts():
    """L'aereo del Volo in coordinate di scena: ruotato di -0,42 in (300, 46)."""
    cs, sn = _m.cos(-0.42), _m.sin(-0.42)

    def rot(pts):
        return [(300 + x * cs - y * sn, 46 + x * sn + y * cs) for x, y in pts]

    body = [(28 + 6 * _m.cos(a), 6 * _m.sin(a)) for a in [(-90 + 15 * i) * _m.pi / 180 for i in range(13)]]
    body += [(-28 + 6 * _m.cos(a), 6 * _m.sin(a)) for a in [(90 + 15 * i) * _m.pi / 180 for i in range(13)]]
    wings = [
        [(6, -4), (-14, -30), (-4, -30), (20, -4)],
        [(6, 4), (-14, 30), (-4, 30), (20, 4)],
        [(-28, -4), (-38, -18), (-31, -18), (-20, -4)],
    ]
    return [rot(body)] + [rot(w) for w in wings]


def _flight(self, plane=INK, trail=COB, clouds=WHITE, sun=None, moon_sky=None):
    X, Y = self.X, self.Y
    if sun:
        self.circle(X(66), Y(116), 54 * self.K, sun, "Sole")
    if moon_sky:
        self.moon(X(66), Y(76), 35 * self.K, moon_sky)
    for x, y, r in ((0, 228, 44), (64, 214, 52), (132, 232, 42), (196, 218, 50), (262, 232, 44), (330, 214, 56)):
        self.circle(X(x), Y(y), r * self.K, clouds, "Nuvola bassa")
    for i in range(7):
        t = i / 7
        cx, cy = 96 + t * 170, 150 - _m.sin(t * _m.pi / 2) * 92
        a = -0.5 + t * 0.2
        ca, sa = _m.cos(a), _m.sin(a)
        pts = [(cx + x * ca - y * sa, cy + x * sa + y * ca) for x, y in ((-8, -2.5), (8, -2.5), (8, 2.5), (-8, 2.5))]
        self.vec("Scia", _poly([(X(px), Y(py)) for px, py in pts]), fill=trail)
    for k, part in enumerate(_plane_parts()):
        self.vec("Aereo" if k == 0 else "Ala", _poly([(X(px), Y(py)) for px, py in part]), fill=plane)


def _crescent(cx, cy, r, bx, by, br, n=40):
    """Falce: il disco (cx, cy, r) meno il disco (bx, by, br), senza ombra."""
    dx, dy = bx - cx, by - cy
    dist = _m.hypot(dx, dy)
    a0 = _m.atan2(dy, dx)
    # Mezzo angolo della corda comune, visto dai due centri.
    d1 = _m.acos((r * r + dist * dist - br * br) / (2 * r * dist))
    d2 = _m.acos((br * br + dist * dist - r * r) / (2 * br * dist))
    out = [a0 + d1 + (2 * _m.pi - 2 * d1) * i / n for i in range(n + 1)]
    pts = [(cx + r * _m.cos(t), cy + r * _m.sin(t)) for t in out]
    # Ritorno lungo il bordo del morso, dalla parte dentro la luna.
    inn = [a0 + _m.pi + d2 - 2 * d2 * i / n for i in range(n + 1)]
    pts += [(bx + br * _m.cos(t), by + br * _m.sin(t)) for t in inn]
    return pts


def _camp(self, moon=SOLE, ground=LAG, tent=FEN, door=INK, stars=True):
    X, Y = self.X, self.Y
    if stars:
        for x, y, r in ((56, 40, 2), (150, 16, 2.5), (226, 56, 1.8), (330, 30, 2.4), (96, 84, 1.6)):
            self.circle(X(x), Y(y), r * self.K, WHITE, "Stella")
    self.vec("Luna", _poly([(X(x), Y(y)) for x, y in _crescent(304, 84, 34, 290, 76, 30)]), fill=moon)
    self.vec("Prato", f"M0 {Y(170)} C{X(110)} {Y(118)} {X(240)} {Y(170)} {X(372)} {Y(132)} L{X(372)} {Y(240)} L0 {Y(240)} Z", fill=ground)
    self.vec("Tenda", _poly([(X(218), Y(84)), (X(292), Y(176)), (X(144), Y(176))]), fill=tent)
    self.vec("Porta", _poly([(X(218), Y(118)), (X(244), Y(176)), (X(192), Y(176))]), fill=door)


Poster.flight = _flight
Poster.camp = _camp
