# Scena "Città" condivisa: stesse coordinate di PosterPainter._city (372 x 240).
from figcraft_kit import scale_path

BACK = ("M0 150 V112 H34 V100 H70 V112 H92 V100 H98 C98 72 116 52 130 48 V30 H126 L136 14 L146 30 H142 V48 "
        "C156 52 174 72 174 100 H180 V108 H212 V38 H208 L229 12 L250 38 H246 V104 H290 V92 H330 V110 H372 V150 Z")
OPEN = ("M219 72 V56 C219 50 226 50 226 56 V72 Z M232 72 V56 C232 50 239 50 239 56 V72 Z M225 104 V92 C225 88 233 88 233 92 V104 Z "
        "M106 122 V112 C106 106 116 106 116 112 V122 Z M124 122 V112 C124 106 134 106 134 112 V122 Z "
        "M142 122 V112 C142 106 152 106 152 112 V122 Z M160 122 V112 C160 106 170 106 170 112 V122 Z")
RIBS = "M136 50 C128 62 124 80 124 100 M136 50 C144 62 148 80 148 100"
FRONT = ("M0 240 V134 L24 114 L48 134 V122 H96 V134 L118 116 L140 134 V126 H188 L210 110 L232 126 V134 H270 "
         "L292 114 L314 134 V124 H372 V240 Z")
WINDOWS = [(12, 136), (30, 136), (62, 130), (80, 130), (110, 136), (126, 136), (156, 132), (172, 132), (202, 128), (218, 128), (284, 130), (298, 130), (330, 130), (350, 130)]
WIN = " ".join(f"M{x} {y} H{x + 7} V{y + 11} H{x} Z" for x, y in WINDOWS)


def city_cmds(parent, ox, oy, k, bg, cob, cobd, sole, absolute=False):
    """Comandi node.create per la scena; `parent` è un id o un riferimento {"$ref": ...}."""
    cmds = []
    extra = {"absolute": True} if absolute else {}

    def add(name, path, **props):
        cmds.append({"command": "node.create", "params": {"type": "vector", "parent": parent, "name": name, "x": ox, "y": oy, "path": scale_path(path, k), "props": {**props, **extra}}})

    add("Città fondo", BACK, fill=cob)
    add("Città aperture", OPEN, fill=bg)
    add("Città cupola", RIBS, fill="none", stroke=cobd, strokeWeight=3 * k)
    add("Città fronte", FRONT, fill=cobd)
    add("Città finestre", WIN, fill=sole)
    return cmds
