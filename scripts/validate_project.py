"""Source and Web export integrity checks, independent of Godot's exit code."""
from pathlib import Path
import re
import sys
import xml.etree.ElementTree as ET

root = Path(__file__).resolve().parents[1]
errors = []
for path in [*root.rglob("*.tscn"), root / "project.godot"]:
    if ".godot" in path.parts or "build" in path.parts:
        continue
    for reference in re.findall(r'res://[^"\n]+', path.read_text(encoding="utf-8")):
        if not (root / reference[6:]).is_file():
            errors.append(f"{path.relative_to(root)}: missing {reference}")
for path in (root / "adventure/art").glob("*.svg"):
    ET.parse(path)
    if any(token in path.read_text() for token in ["data:image", "<image", "http://github", "<script"]):
        errors.append("Unexpected image/script embed in " + path.name)
for path in [*root.glob("*.gd"), *root.glob("adventure/**/*.gd")]:
    if re.search(r"Fóffins|Fofins|Foffins|[\u2190-\u2193]", path.read_text()):
        errors.append("Unsupported name or arrow glyph in " + path.name)
if len(sys.argv) > 1:
    export = Path(sys.argv[1])
    for name in ["index.html", "index.js", "index.wasm", "index.pck"]:
        path = export / name
        if not path.is_file() or path.stat().st_size == 0:
            errors.append("Missing Web export: " + name)
    if (export / "index.html").exists() and "const GODOT_THREADS_ENABLED = false" not in (export / "index.html").read_text():
        errors.append("Web export must use one thread for GitHub Pages")
if errors:
    raise SystemExit("\n".join(errors))
print("Source references, SVGs, spelling, keyboard-safe text and Web files verified.")
