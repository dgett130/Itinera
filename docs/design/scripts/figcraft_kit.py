# Kit per disegnare le maschere di Itinera in FigCraft.
#
# Parla con l'app tramite `figcraft-cli mcp --attach 47920` (JSON-RPC su stdio):
# l'app va aperta dal collegamento "FigCraft (Claude)", che abilita la porta 47920.
# Uno script di pagina costruisce un Doc con gli helper qui sotto e chiama
# publish(doc, etichetta, nome_pagina): la pagina viene sostituita per intero.
# Con la variabile d'ambiente DARK=1 lo stesso script disegna la versione scura
# in una pagina "<nome> · scuro".
import json
import os
import re
import subprocess

CLI = r"C:\Program Files\ArtCraft\FigCraft\figcraft-cli.exe"
PORT = "47920"

# Colori Cartolina (vedi lib/ui/itinera_theme.dart).
COB, COBD, SOLE, FEN, LAG, INK, CARTA = "#1B3FD8", "#0E2AA8", "#FFC21A", "#FF7A59", "#12B6BE", "#11153A", "#F5F6FB"
CORALLO = FEN
WHITE, MUTED, HAIR, POS, WARN = "#FFFFFF", "#565C85", "#DFE2F0", "#0A7F86", "#C2410C"
BRI, FIG = "Bricolage Grotesque", "Figtree"
DARK = os.environ.get("DARK") == "1"

# Icone Material (box 24).
I = dict(
    back="M20 11H7.83l5.59-5.59L12 4l-8 8 8 8 1.41-1.41L7.83 13H20v-2z",
    plus="M19 13h-6v6h-2v-6H5v-2h6V5h2v6h6v2z",
    minus="M19 13H5v-2h14v2z",
    more="M12 8c1.1 0 2-.9 2-2s-.9-2-2-2-2 .9-2 2 .9 2 2 2zm0 2c-1.1 0-2 .9-2 2s.9 2 2 2 2-.9 2-2-.9-2-2-2zm0 6c-1.1 0-2 .9-2 2s.9 2 2 2 2-.9 2-2-.9-2-2-2z",
    check="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z",
    close="M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z",
    search="M15.5 14h-.79l-.28-.27C15.41 12.59 16 11.11 16 9.5 16 5.91 13.09 3 9.5 3S3 5.91 3 9.5 5.91 16 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z",
    star="M12 17.27L18.18 21l-1.64-7.03L22 9.24l-7.19-.61L12 2 9.19 8.63 2 9.24l5.46 4.73L5.82 21z",
    doc="M14 2H6c-1.1 0-1.99.9-1.99 2L4 20c0 1.1.89 2 1.99 2H18c1.1 0 2-.9 2-2V8l-6-6zm2 16H8v-2h8v2zm0-4H8v-2h8v2zm-3-5V3.5L18.5 9H13z",
    image="M21 19V5c0-1.1-.9-2-2-2H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2zM8.5 13.5l2.5 3.01L14.5 12l4.5 6H5l3.5-4.5z",
    bell="M12 22c1.1 0 2-.9 2-2h-4c0 1.1.9 2 2 2zm6-6v-5c0-3.07-1.63-5.64-4.5-6.32V4c0-.83-.67-1.5-1.5-1.5s-1.5.67-1.5 1.5v.68C7.64 5.36 6 7.92 6 11v5l-2 2v1h16v-1l-2-2z",
    people="M16 11c1.66 0 2.99-1.34 2.99-3S17.66 5 16 5c-1.66 0-3 1.34-3 3s1.34 3 3 3zm-8 0c1.66 0 2.99-1.34 2.99-3S9.66 5 8 5C6.34 5 5 6.34 5 8s1.34 3 3 3zm0 2c-2.33 0-7 1.17-7 3.5V19h14v-2.5c0-2.33-4.67-3.5-7-3.5zm8 0c-.29 0-.62.02-.97.05 1.16.84 1.97 1.97 1.97 3.45V19h6v-2.5c0-2.33-4.67-3.5-7-3.5z",
    luggage="M17 6h-2V3c0-.55-.45-1-1-1h-4c-.55 0-1 .45-1 1v3H7c-1.1 0-2 .9-2 2v11c0 1.1.9 2 2 2 0 .55.45 1 1 1s1-.45 1-1h6c0 .55.45 1 1 1s1-.45 1-1c1.1 0 2-.9 2-2V8c0-1.1-.9-2-2-2zM9.5 18H8V9h1.5v9zm3.25 0h-1.5V9h1.5v9zm.75-12h-3V3.5h3V6zM16 18h-1.5V9H16v9z",
    car="M18.92 6.01C18.72 5.42 18.16 5 17.5 5h-11c-.66 0-1.21.42-1.42 1.01L3 12v8c0 .55.45 1 1 1h1c.55 0 1-.45 1-1v-1h12v1c0 .55.45 1 1 1h1c.55 0 1-.45 1-1v-8l-2.08-5.99zM6.5 16c-.83 0-1.5-.67-1.5-1.5S5.67 13 6.5 13s1.5.67 1.5 1.5S7.33 16 6.5 16zm11 0c-.83 0-1.5-.67-1.5-1.5s.67-1.5 1.5-1.5 1.5.67 1.5 1.5-.67 1.5-1.5 1.5zM5 11l1.5-4.5h11L19 11H5z",
    ferry="M20 21c-1.39 0-2.78-.47-4-1.32-2.44 1.71-5.56 1.71-8 0C6.78 20.53 5.39 21 4 21H2v2h2c1.38 0 2.74-.35 4-.99 2.52 1.29 5.48 1.29 8 0 1.26.65 2.62.99 4 .99h2v-2h-2zM3.95 19H4c1.6 0 3.02-.88 4-2 .98 1.12 2.4 2 4 2s3.02-.88 4-2c.98 1.12 2.4 2 4 2h.05l1.89-6.68c.08-.26.06-.54-.06-.78s-.34-.42-.6-.5L20 10.62V6c0-1.1-.9-2-2-2h-3V1H9v3H6c-1.1 0-2 .9-2 2v4.62l-1.29.42c-.26.08-.48.26-.6.5s-.15.52-.06.78L3.95 19zM6 6h12v3.97L12 8 6 9.97V6z",
    gear="M19.14 12.94c.04-.3.06-.61.06-.94 0-.32-.02-.64-.07-.94l2.03-1.58c.18-.14.23-.41.12-.61l-1.92-3.32c-.12-.22-.37-.29-.59-.22l-2.39.96c-.5-.38-1.03-.7-1.62-.94l-.36-2.54c-.04-.24-.24-.41-.48-.41h-3.84c-.24 0-.43.17-.47.41l-.36 2.54c-.59.24-1.13.57-1.62.94l-2.39-.96c-.22-.08-.47 0-.59.22L2.74 8.87c-.12.21-.08.47.12.61l2.03 1.58c-.05.3-.09.63-.09.94s.02.64.07.94l-2.03 1.58c-.18.14-.23.41-.12.61l1.92 3.32c.12.22.37.29.59.22l2.39-.96c.5.38 1.03.7 1.62.94l.36 2.54c.05.24.24.41.48.41h3.84c.24 0 .44-.17.47-.41l.36-2.54c.59-.24 1.13-.56 1.62-.94l2.39.96c.22.08.47 0 .59-.22l1.92-3.32c.12-.22.07-.47-.12-.61l-2.01-1.58zM12 15.6c-1.98 0-3.6-1.62-3.6-3.6s1.62-3.6 3.6-3.6 3.6 1.62 3.6 3.6-1.62 3.6-3.6 3.6z",
    place="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7zm0 9.5c-1.38 0-2.5-1.12-2.5-2.5s1.12-2.5 2.5-2.5 2.5 1.12 2.5 2.5-1.12 2.5-2.5 2.5z",
    person="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z",
    chevron="M10 6L8.59 7.41 13.17 12l-4.58 4.59L10 18l6-6z",
    down="M7 10l5 5 5-5z",
    drag="M4 9h16v2H4V9zm0 4h16v2H4v-2z",
    walk="M13.5 5.5c1.1 0 2-.9 2-2s-.9-2-2-2-2 .9-2 2 .9 2 2 2zM9.8 8.9L7 23h2.1l1.8-8 2.1 2v6h2v-7.5l-2.1-2 .6-3C14.8 12 16.8 13 19 13v-2c-1.9 0-3.5-1-4.3-2.4l-1-1.6c-.4-.6-1-1-1.7-1-.3 0-.5.1-.8.1L6 8.3V13h2V9.6l1.8-.7",
    clock="M11.99 2C6.47 2 2 6.48 2 12s4.47 10 9.99 10C17.52 22 22 17.52 22 12S17.52 2 11.99 2zM12 20c-4.42 0-8-3.58-8-8s3.58-8 8-8 8 3.58 8 8-3.58 8-8 8zm.5-13H11v6l5.25 3.15.75-1.23-4.5-2.67z",
    info="M11 7h2v2h-2V7zm0 4h2v6h-2v-6zm1-9C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 18c-4.41 0-8-3.59-8-8s3.59-8 8-8 8 3.59 8 8-3.59 8-8 8z",
    warn="M1 21h22L12 2 1 21zm12-3h-2v-2h2v2zm0-4h-2v-4h2v4z",
    upload="M9 16h6v-6h4l-7-7-7 7h4v6zm-4 2h14v2H5v-2z",
    download="M19 9h-4V3H9v6H5l7 7 7-7zM5 18v2h14v-2H5z",
    calendar="M19 4h-1V2h-2v2H8V2H6v2H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V6c0-1.1-.9-2-2-2zm0 16H5V9h14v11z",
    send="M2.01 21L23 12 2.01 3 2 10l15 2-15 2z",
    trash="M6 19c0 1.1.9 2 2 2h8c1.1 0 2-.9 2-2V7H6v12zM19 4h-3.5l-1-1h-5l-1 1H5v2h14V4z",
    open="M19 19H5V5h7V3H5a2 2 0 00-2 2v14a2 2 0 002 2h14c1.1 0 2-.9 2-2v-7h-2v7zM14 3v2h3.59l-9.83 9.83 1.41 1.41L19 6.41V10h2V3h-7z",
    route="M19 15.18V7c0-2.21-1.79-4-4-4s-4 1.79-4 4v10c0 1.1-.9 2-2 2s-2-.9-2-2V8.82C8.16 8.4 9 7.3 9 6c0-1.66-1.34-3-3-3S3 4.34 3 6c0 1.3.84 2.4 2 2.82V17c0 2.21 1.79 4 4 4s4-1.79 4-4V7c0-1.1.9-2 2-2s2 .9 2 2v8.18A3 3 0 0015 18c0 1.66 1.34 3 3 3s3-1.34 3-3a3 3 0 00-2-2.82z",
    moon="M12 3a9 9 0 109 9c0-.46-.04-.92-.1-1.36a5.4 5.4 0 01-4.4 2.26 5.4 5.4 0 01-3.14-9.8c-.44-.06-.9-.1-1.36-.1z",
)

_ARGS = dict(m=2, l=2, h=1, v=1, c=6, s=4, q=4, t=2, a=7, z=0)


def bbox(path):
    """Box del path, punti di controllo compresi (approssimato per eccesso)."""
    path = re.sub(r"([aA]\s*[\d.\-]+[ ,]*[\d.\-]+[ ,]*[\d.\-]+[ ,]+)([01])[ ,]*([01])[ ,]*", r"\1\2 \3 ", path)
    toks = re.findall(r"[a-zA-Z]|-?\d*\.?\d+(?:e-?\d+)?", path)
    i, x, y, sx, sy, cmd = 0, 0.0, 0.0, 0.0, 0.0, None
    xs, ys = [], []
    while i < len(toks):
        if toks[i].isalpha():
            cmd = toks[i]
            i += 1
            if cmd in "zZ":
                x, y = sx, sy
                continue
        lc = cmd.lower()
        n = _ARGS[lc]
        a = [float(t) for t in toks[i:i + n]]
        i += n
        rel = cmd.islower()
        if lc == "h":
            x = a[0] + (x if rel else 0)
        elif lc == "v":
            y = a[0] + (y if rel else 0)
        elif lc == "a":
            x, y = a[5] + (x if rel else 0), a[6] + (y if rel else 0)
        else:
            ox, oy = x, y
            for k in range(0, n, 2):
                px, py = a[k] + (ox if rel else 0), a[k + 1] + (oy if rel else 0)
                xs.append(px)
                ys.append(py)
                x, y = px, py
        xs.append(x)
        ys.append(y)
        if lc == "m":
            sx, sy = x, y
            cmd = "l" if rel else "L"
    return min(xs), min(ys), max(xs), max(ys)


def scale_path(path, k):
    """Moltiplica per k tutte le coordinate di un path assoluto."""
    return re.sub(r"-?\d+\.?\d*", lambda m: f"{float(m.group()) * k:.2f}", path)


class Doc:
    """Accumula i comandi; ogni helper ritorna il riferimento al nodo creato."""

    def __init__(self, dark=None):
        self.cmds = []
        self.n = 0
        self.y0 = 0
        self.set_dark(DARK if dark is None else dark)

    def set_dark(self, dark):
        self.dark = dark
        self.bg = "#0C0F2B" if dark else CARTA
        self.card_bg = "#171B45" if dark else WHITE
        self.card_high = "#20255A" if dark else "#E7ECFF"
        self.on = CARTA if dark else INK
        self.muted = "#A9B0DA" if dark else MUTED
        self.hair = "#2B3066" if dark else HAIR
        self.accent = "#9DAEFF" if dark else COB
        self.pos = LAG if dark else POS
        self.warn = "#FFB14A" if dark else WARN
        self.warn_bg = "#3A2A25" if dark else "#FFF3D1"
        self.cta_bg = SOLE if dark else INK
        self.on_cta = INK if dark else WHITE
        self.panel = "#20255A" if dark else INK

    def node(self, type, parent=None, name=None, x=None, y=None, w=None, h=None, path=None, text=None, **props):
        self.n += 1
        ref = f"n{self.n}"
        p = {"type": type}
        if parent is not None:
            p["parent"] = parent if isinstance(parent, (int, dict)) else {"$ref": parent}
        if name:
            p["name"] = name
        if x is not None:
            p["x"] = x
        if y is not None:
            p["y"] = y
        if w is not None:
            p["width"] = w
        if h is not None:
            p["height"] = h
        if path:
            p["path"] = path
        if "index" in props:
            p["index"] = props.pop("index")
        if text is not None:
            p["text"] = text
        if props:
            p["props"] = props
        self.cmds.append({"command": "node.create", "as": ref, "params": p})
        return ref

    # --- struttura -----------------------------------------------------
    def frame(self, parent, name="Gruppo", dir="vertical", gap=0, pad=0, fill="none", w=None, h=None, H=None, V="hug", **kw):
        H = H or ("fixed" if w else "fill")
        V = "fixed" if h else V
        return self.node("frame", parent, name, w=w, h=h, fill=fill, layout=dir, gap=gap, padding=pad, sizingH=H, sizingV=V, **kw)

    def row(self, parent, name="Riga", gap=8, pad=0, cross="center", main=None, fill="none", **kw):
        if main:
            kw["mainAlign"] = main
        return self.frame(parent, name, "horizontal", gap, pad, fill, crossAlign=cross, **kw)

    def wrap(self, parent, name="Gruppo", gap=8):
        return self.frame(parent, name, "horizontal", gap, wrap=True, crossGap=gap)

    def two(self, parent, name="Due campi", gap=10):
        return self.frame(parent, name, "horizontal", gap)

    def screen(self, name, x, h=917, y=None, pad=None, gap=0, fill=None):
        kw = dict(fill=fill or self.bg, clip=True, cornerRadius=28, layout="vertical", gap=gap)
        if pad is not None:
            kw["padding"] = pad
        return self.node("frame", None, name, x=x, y=self.y0 if y is None else y, w=412, h=h, **kw)

    def header(self, root, color, title, note=None, fg=INK, back=True, gap=8, sub=None, size=36):
        hd = self.frame(root, "Testata", gap=gap, pad=[46, 20, 20, 20], fill=color, cornerRadius=[0, 0, 32, 32])
        if back:
            self.icon(hd, "back", fg, 24)
        self.text(hd, title, BRI, "ExtraBold", size, fg, name="Titolo", lh=size + 2, fillw=True)
        if note:
            self.text(hd, note, FIG, "Medium", 15, sub or fg, name="Nota", fillw=True)
        return hd

    def plain_header(self, root, title, note=None, back=True, actions=(), size=36):
        hd = self.frame(root, "Testata", gap=8, pad=[46, 20, 12, 20])
        top = self.row(hd, "Barra", main="spaceBetween", H="fill")
        if back:
            self.icon(top, "back", self.on, 24)
        else:
            self.node("frame", top, "Spazio", w=1, h=24, fill="none")
        if actions:
            a = self.row(top, "Azioni", gap=14, H="hug")
            for ic in actions:
                if ic in I:
                    self.icon(a, ic, self.on, 24)
                else:
                    self.text(a, ic, BRI, "Bold", 14, self.accent)
        self.text(hd, title, BRI, "ExtraBold", size, self.on, name="Titolo", lh=size + 2, fillw=True)
        if note:
            self.text(hd, note, FIG, "Regular", 15, self.muted, fillw=True)
        return hd

    def content(self, root, gap=12, pad=(16, 20, 0, 20)):
        return self.frame(root, "Contenuto", gap=gap, pad=list(pad), V="fill")

    # --- primitivi -----------------------------------------------------
    def text(self, parent, s, font=FIG, style="Regular", size=15, color=None, name=None, lh=None, fillw=False, w=None, align=None):
        kw = dict(fontFamily=font, fontStyle=style, fontSize=size, fill=color or self.on)
        if lh:
            kw["lineHeight"] = lh
        if fillw:
            kw["sizingH"] = "fill"
        if align:
            kw["textAlign"] = align
        return self.node("text", parent, name, text=s, w=w, **kw)

    def h2(self, parent, s, color=None):
        return self.text(parent, s, BRI, "Bold", 20, color or self.on, name="Sezione")

    def title(self, parent, s, color=None, size=17, fillw=True):
        return self.text(parent, s, BRI, "Bold", size, color or self.on, fillw=fillw)

    def note(self, parent, s, color=None, size=14, fillw=True, style="Regular"):
        return self.text(parent, s, FIG, style, size, color or self.muted, fillw=fillw)

    def icon(self, parent, key, color=None, size=24, x=None, y=None):
        # Le icone mantengono la scala del box 24, qualunque sia il loro ingombro.
        try:
            if key in ("google", "palette"):
                raise ValueError
            x0, y0, x1, y1 = bbox(I[key])
        except ValueError:
            x0, y0, x1, y1 = 2, 2, 22, 22
        k = size / 24
        return self.node("vector", parent, key, x=x, y=y, w=max(1, (x1 - x0) * k), h=max(1, (y1 - y0) * k), path=I[key], fill=color or self.on)

    def tile(self, parent, key, bg, fg=INK, size=48, radius=14, ic=24):
        t = self.node("frame", parent, "Icona", w=size, h=size, fill=bg, cornerRadius=radius, layout="horizontal", mainAlign="center", crossAlign="center")
        self.icon(t, key, fg, ic)
        return t

    def avatar(self, parent, letter, bg, fg=INK, size=48):
        t = self.node("frame", parent, "Avatar", w=size, h=size, fill=bg, cornerRadius=size / 2, layout="horizontal", mainAlign="center", crossAlign="center")
        self.text(t, letter, BRI, "ExtraBold", size * 0.46, fg)
        return t

    def card(self, parent, name="Scheda", dir="horizontal", gap=12, pad=14, fill=None, stroke=None, radius=20, **kw):
        if dir == "horizontal":
            kw.setdefault("crossAlign", "center")
        return self.frame(parent, name, dir, gap, pad, fill or self.card_bg, stroke=stroke or self.hair, strokeWeight=1, cornerRadius=radius, **kw)

    def texts(self, parent, title, note=None, gap=2, note_color=None, title_color=None):
        t = self.frame(parent, "Testi", gap=gap)
        self.title(t, title, title_color)
        if note:
            self.note(t, note, note_color)
        return t

    def list_row(self, parent, leading, title, note=None, trailing=None, note_color=None):
        """leading: callable(card) o None; trailing: chiave icona o callable(card)."""
        c = self.card(parent, title)
        if leading:
            leading(c)
        self.texts(c, title, note, note_color=note_color)
        if callable(trailing):
            trailing(c)
        elif trailing:
            self.icon(c, trailing, self.muted, 24)
        return c

    def field(self, parent, label, value=None, active=False, hint=None, multiline=False, H="fill", trailing=None, error=None):
        """Campo con l'etichetta dentro, come nell'app."""
        col = self.accent if active else self.muted
        c = self.frame(parent, label, "horizontal" if trailing else "vertical", 2, [10, 16, 10, 16], self.card_bg, H=H,
                       stroke=(self.warn if error else (self.accent if active else self.hair)), strokeWeight=2 if active or error else 1, cornerRadius=16,
                       **({"crossAlign": "center"} if trailing else {}))
        inner = self.frame(c, "Testi", gap=2) if trailing else c
        self.text(inner, label, FIG, "Regular", 12, col, fillw=True)
        self.text(inner, value if value else (hint or " "), FIG, "Regular", 16, self.on if value else self.muted, fillw=True, lh=22 if multiline else None)
        if trailing:
            self.icon(c, trailing, self.muted, 22)
        return c

    def chip(self, parent, s, on=False, color=SOLE, fg=INK):
        c = self.frame(parent, s, "horizontal", 0, [8, 16, 8, 16], color if on else self.card_bg, H="hug",
                       cornerRadius=20, **({} if on else {"stroke": self.hair, "strokeWeight": 1}))
        self.text(c, s, FIG, "SemiBold", 14, fg if on else self.on)
        return c

    def tag(self, parent, s, bg, fg=INK):
        c = self.frame(parent, s, "horizontal", 0, [3, 10, 3, 10], bg, H="hug", cornerRadius=12)
        self.text(c, s, FIG, "SemiBold", 12, fg)
        return c

    def cta(self, parent, s, bg=None, fg=None, icon=None, outlined=False, H="fill", h=56, size=17):
        bg = bg or self.cta_bg
        fg = fg or self.on_cta
        kw = dict(cornerRadius=h / 2, mainAlign="center", crossAlign="center")
        if outlined:
            kw.update(stroke=self.on, strokeWeight=1.5)
            fg = self.on
            bg = "none"
        if H == "hug":
            c = self.node("frame", parent, s, h=h, fill=bg, layout="horizontal", gap=8, padding=[0, 20, 0, 20], sizingH="hug", sizingV="fixed", **kw)
        else:
            c = self.node("frame", parent, s, h=h, fill=bg, layout="horizontal", gap=8, sizingH="fill", sizingV="fixed", **kw)
        if icon:
            self.icon(c, icon, fg, 20)
        self.text(c, s, BRI, "Bold", size, fg)
        return c

    def fab(self, root, s, w, tint=SOLE, height=917, y=None):
        y = y if y is not None else height - 76
        f = self.node("frame", root, s, x=412 - 20 - w, y=y, w=w, h=56, absolute=True, fill=self.cta_bg, cornerRadius=28, layout="horizontal", mainAlign="center", crossAlign="center", gap=6)
        self.icon(f, "plus", INK if self.dark else tint, 20)
        self.text(f, s, BRI, "Bold", 17, self.on_cta)
        return f

    def switch(self, parent, on=True, color=None):
        color = color or (SOLE if self.dark else self.accent)
        s = self.node("frame", parent, "Interruttore", w=48, h=28, fill=color if on else self.hair, cornerRadius=14, clip=False)
        self.node("ellipse", s, "Pomello", x=23 if on else 3, y=3, w=22, h=22, fill=INK if (on and self.dark) else WHITE)
        return s

    def stepper(self, parent, label, value, sub=None):
        c = self.frame(parent, label, "horizontal", 8, [8, 8, 8, 16], self.card_bg, stroke=self.hair, strokeWeight=1, cornerRadius=16, crossAlign="center")
        t = self.frame(c, "Testi", gap=2)
        self.text(t, label, FIG, "Medium", 16, self.on, fillw=True)
        if sub:
            self.note(t, sub, size=13)
        s = self.row(c, "Contatore", gap=14, H="hug")
        m = self.node("frame", s, "Meno", w=40, h=40, fill="none", stroke=self.on, strokeWeight=1.5, cornerRadius=20, layout="horizontal", mainAlign="center", crossAlign="center")
        self.icon(m, "minus", self.on, 18)
        self.text(s, value, BRI, "ExtraBold", 22, self.on)
        p = self.node("frame", s, "Più", w=40, h=40, fill=self.cta_bg, cornerRadius=20, layout="horizontal", mainAlign="center", crossAlign="center")
        self.icon(p, "plus", self.on_cta, 18)
        return c

    def segmented(self, parent, items, on=0, track=None, active=None, active_fg=None, fg=None):
        track = track or (self.card_bg if not self.dark else "#20255A")
        active = active or self.cta_bg
        active_fg = active_fg or self.on_cta
        t = self.frame(parent, "Selettore", "horizontal", 0, 4, track, cornerRadius=24, stroke=self.hair, strokeWeight=1)
        for i, s in enumerate(items):
            cell = self.node("frame", t, s, h=40, fill=active if i == on else "none", cornerRadius=20, layout="horizontal", mainAlign="center", crossAlign="center", sizingH="fill", sizingV="fixed")
            self.text(cell, s, BRI, "Bold", 15, active_fg if i == on else (fg or self.on))
        return t

    def sheet(self, x, title, h=917, y=None, name=None, title_size=26):
        """Foglio dal basso su sfondo velato; publish() lo ancora al fondo."""
        root = self.node("frame", None, name or title, x=x, y=self.y0 if y is None else y, w=412, h=h, fill="#11153A99", clip=True, cornerRadius=28)
        s = self.node("frame", root, "Foglio", x=0, y=120, w=412, fill=self.bg, cornerRadius=[28, 28, 0, 0], layout="vertical", gap=12, padding=[10, 20, 24, 20], sizingV="hug")
        grab = self.row(s, "Maniglia", main="center", H="fill")
        self.node("frame", grab, "Tacca", w=44, h=4, fill=self.hair, cornerRadius=2)
        self.text(s, title, BRI, "ExtraBold", title_size, self.on, name="Titolo", fillw=True)
        return s


class Client:
    """Collegamento all'app FigCraft aperta (figcraft-cli mcp --attach)."""

    def __init__(self):
        self.p = subprocess.Popen([CLI, "mcp", "--attach", PORT, "--timeout", "120"], stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL)
        self.i = 0
        self.call("initialize", {"protocolVersion": "2024-11-05", "capabilities": {}, "clientInfo": {"name": "itinera-maschere", "version": "1"}})
        self.p.stdin.write(b'{"jsonrpc":"2.0","method":"notifications/initialized"}\n')
        self.p.stdin.flush()

    def call(self, method, params):
        self.i += 1
        self.p.stdin.write((json.dumps({"jsonrpc": "2.0", "id": self.i, "method": method, "params": params}) + "\n").encode())
        self.p.stdin.flush()
        while True:
            line = self.p.stdout.readline()
            if not line:
                raise RuntimeError("figcraft-cli chiusa: l'app e' aperta dal collegamento 'FigCraft (Claude)'?")
            m = json.loads(line)
            if m.get("id") == self.i:
                return m

    def tool(self, name, args):
        m = self.call("tools/call", {"name": name, "arguments": args})
        if "error" in m:
            raise RuntimeError(m["error"])
        r = m["result"]
        txt = " ".join(c.get("text", "") for c in r.get("content", []))
        if r.get("isError"):
            raise RuntimeError(txt[:800])
        return txt

    def close(self):
        self.p.stdin.close()
        self.p.wait(timeout=10)


DESIGN_FILE = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "itinera-identita.figcraft"))


def ensure_file(c):
    """Porta in primo piano il file delle maschere (lo apre se serve)."""
    info = json.loads(c.tool("inspect_document", {"depth": 0, "fields": ["name"]}))
    if os.path.normcase(info.get("path") or "") != os.path.normcase(DESIGN_FILE):
        c.tool("open_file", {"path": DESIGN_FILE})


def publish(doc, label, page):
    """Sostituisce la pagina `page` col contenuto del doc e ancora i fogli al fondo."""
    if doc.dark:
        page += " · scuro"
    c = Client()
    try:
        ensure_file(c)
        pages = json.loads(c.tool("run_command", {"command": "page.list"}))
        pages = pages["pages"] if isinstance(pages, dict) else pages
        old = [p["id"] for p in pages if p["name"] == page]
        cmds = [{"command": "page.add", "as": "pg", "params": {"name": page}}]
        cmds += [{"command": "page.delete", "params": {"id": i}} for i in old]
        ids = json.loads(c.tool("batch", {"commands": cmds + doc.cmds, "label": label}))
        print(label, "ok", len(ids), "passi")
        tree = json.loads(c.tool("inspect_document", {"depth": 2, "fields": ["name", "height"]}))
        cur = next(p for p in tree["pages"] if p["id"] == tree["currentPage"])
        fix = []
        for fr in cur.get("children", []):
            sh = [k for k in fr.get("children", []) if k["name"] == "Foglio"]
            if not sh:
                continue
            H, sh_h = fr["height"], sh[0]["height"]
            if sh_h + 70 > H:
                H = sh_h + 70
                fix.append({"command": "node.set", "params": {"ids": [fr["id"]], "height": H}})
            fix.append({"command": "node.set", "params": {"ids": [sh[0]["id"]], "y": H - sh_h}})
        if fix:
            c.tool("batch", {"commands": fix, "label": label + " fogli"})
        c.tool("save_file", {})
    finally:
        c.close()


def append(doc, label, page, tag):
    """Aggiunge il doc a una pagina esistente senza toccare il resto.

    I nodi di primo livello col nome che contiene `tag` vengono prima tolti,
    cosi' lo script si puo' rilanciare. Serve per le pagine il cui script e'
    andato perso (es. "K · Movimento")."""
    c = Client()
    try:
        ensure_file(c)
        t = json.loads(c.tool("inspect_document", {"allPages": True, "depth": 1, "fields": ["name"]}))
        pg = next(p for p in t["pages"] if p["name"] == page)
        old = [k["id"] for k in pg.get("children", []) if tag in k["name"]]
        cmds = [{"command": "page.select", "params": {"id": pg["id"]}}]
        if old:
            cmds.append({"command": "edit.delete", "params": {"ids": old}})
        ids = json.loads(c.tool("batch", {"commands": cmds + doc.cmds, "label": label}))
        print(label, "ok", len(ids), "passi")
        c.tool("save_file", {})
    finally:
        c.close()


def frames(page_name):
    """Frame di primo livello di una pagina: lista di (id, nome)."""
    c = Client()
    try:
        ensure_file(c)
        t = json.loads(c.tool("inspect_document", {"allPages": True, "depth": 1, "fields": ["name"]}))
        for p in t["pages"]:
            if p["name"] == page_name:
                return [(k["id"], k["name"]) for k in p.get("children", [])]
        return []
    finally:
        c.close()


def shot(ids, path, max_size=1800):
    """Salva in PNG uno screenshot dei layer indicati."""
    import base64
    c = Client()
    try:
        ensure_file(c)
        m = c.call("tools/call", {"name": "screenshot", "arguments": {"ids": list(ids), "maxSize": max_size}})
        img = next(x for x in m["result"]["content"] if x.get("type") == "image")
        open(path, "wb").write(base64.b64decode(img["data"]))
        return path
    finally:
        c.close()


def pages():
    """Elenco delle pagine del file aperto (per verifiche rapide)."""
    c = Client()
    try:
        ensure_file(c)
        out = json.loads(c.tool("run_command", {"command": "page.list"}))
        return out["pages"] if isinstance(out, dict) else out
    finally:
        c.close()


if __name__ == "__main__":
    import sys
    sys.stdout.reconfigure(encoding="utf-8")
    for p in pages():
        print(p.get("id"), p.get("name"), p.get("children"))
