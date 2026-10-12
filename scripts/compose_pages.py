"""Preserve the already-published official bytes; place the preview only in /teste/."""
import argparse
import hashlib
import json
import re
import shutil
import time
import urllib.request
from pathlib import Path

OFFICIAL_URL = "https://rafaelsantanna13.github.io/Rafinha2D/"

def fetch(url):
    for attempt in range(3):
        try:
            with urllib.request.urlopen(urllib.request.Request(url, headers={"Cache-Control": "no-cache"}), timeout=90) as response:
                return response.read()
        except OSError:
            if attempt == 2:
                raise
            time.sleep(attempt + 1)

def sha(data):
    return hashlib.sha256(data).hexdigest()

def dependencies(html):
    config = re.search(r"const GODOT_CONFIG = (\{.+?\});", html)
    if not config:
        raise ValueError("Official page is not a recognized Godot export. Publication stopped.")
    settings = json.loads(config[1])
    names = {"index.html", settings["executable"] + ".js", *settings["fileSizes"]}
    names.update(re.findall(r'(?:href|src)="([^"/:?#]+\.(?:png|js|ico))"', html))
    for name in names:
        if not re.fullmatch(r"[A-Za-z0-9_.-]+", name) or name in {".", ".."}:
            raise ValueError("Unsafe or unsupported official dependency")
    if settings.get("serviceWorker"):
        raise ValueError("Official service worker requires an explicit preservation review")
    return sorted(names), settings

def compose(preview, output, official_url=OFFICIAL_URL, source_sha="local"):
    preview, output = Path(preview), Path(output)
    if output.exists():
        raise ValueError("Destination already exists; refusing to replace unrelated files")
    for name in ["index.html", "index.pck", "index.wasm", "index.js"]:
        if not (preview / name).is_file() or (preview / name).stat().st_size == 0:
            raise ValueError("Preview export is incomplete: " + name)
    index = fetch(official_url)
    names, config = dependencies(index.decode("utf-8"))
    original = {}
    for name in names:
        payload = index if name == "index.html" else fetch(official_url + name)
        if name in config["fileSizes"] and len(payload) != config["fileSizes"][name]:
            raise ValueError("Official files changed during snapshot; publication stopped")
        original[name] = payload
    # Godot's loader requests AudioWorklets dynamically; they are not in the HTML.
    loader = original[config["executable"] + ".js"].decode("utf-8")
    for suffix in [".audio.worklet.js", ".audio.position.worklet.js"]:
        if suffix in loader:
            name = config["executable"] + suffix
            original[name] = fetch(official_url + name)
    if fetch(official_url) != index:
        raise ValueError("Official index changed during snapshot; publication stopped")
    output.mkdir(parents=True)
    for name, payload in original.items():
        (output / name).write_bytes(payload)
    shutil.copytree(preview, output / "teste")
    (output / ".nojekyll").touch()
    manifest = {"source_sha": source_sha, "official_url": official_url,
                "official_sha256": {name: sha(payload) for name, payload in original.items()},
                "preview_sha256": {p.name: sha(p.read_bytes()) for p in preview.glob("index.*") if p.is_file()}}
    (output / "teste" / "publication.json").write_text(json.dumps(manifest, indent=2), encoding="utf-8")
    verify(output)
    return manifest

def verify(output, check_remote=False):
    output = Path(output)
    manifest = json.loads((output / "teste" / "publication.json").read_text())
    for name, expected in manifest["official_sha256"].items():
        if sha((output / name).read_bytes()) != expected:
            raise ValueError("Official local bytes changed: " + name)
        if check_remote and sha(fetch(manifest["official_url"] + name)) != expected:
            raise ValueError("A newer official version is live. Preview publication stopped: " + name)
    if (output / "index.pck").read_bytes() == (output / "teste" / "index.pck").read_bytes():
        raise ValueError("Official and experimental packs must remain independent")
    return manifest

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--preview", default="build/preview")
    parser.add_argument("--output", default="public")
    parser.add_argument("--source-sha", default="local")
    parser.add_argument("--verify", action="store_true")
    parser.add_argument("--check-remote", action="store_true")
    args = parser.parse_args()
    result = verify(args.output, args.check_remote) if args.verify else compose(args.preview, args.output, source_sha=args.source_sha)
    print("Official bytes preserved:", len(result["official_sha256"]), "files. Preview:", args.source_sha)
