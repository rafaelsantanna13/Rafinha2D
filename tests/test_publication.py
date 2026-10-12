import importlib.util
import json
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

SPEC = importlib.util.spec_from_file_location("compose", Path(__file__).resolve().parents[1] / "scripts/compose_pages.py")
compose = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(compose)

class PublicationTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)
        self.preview = self.root / "preview"
        self.preview.mkdir()
        for name in ["index.html", "index.pck", "index.wasm", "index.js"]:
            (self.preview / name).write_bytes(b"experimental:" + name.encode())
        config = {"executable": "index", "fileSizes": {"index.pck": 8, "index.wasm": 8}}
        self.official = {"index.html": ('<script>const GODOT_CONFIG = ' + json.dumps(config) + ';</script><img src="index.png">').encode(),
                         "index.pck": b"official", "index.wasm": b"wasmfile", "index.js": b"javascript", "index.png": b"splash"}
        self.output = self.root / "public"

    def tearDown(self):
        self.temp.cleanup()

    def fetch(self, url):
        return self.official[url.removeprefix(compose.OFFICIAL_URL) or "index.html"]

    def test_official_bytes_and_preview_are_independent(self):
        with patch.object(compose, "fetch", self.fetch):
            manifest = compose.compose(self.preview, self.output)
            compose.verify(self.output, True)
        for name, data in self.official.items():
            self.assertEqual((self.output / name).read_bytes(), data)
        self.assertNotEqual((self.output / "index.pck").read_bytes(), (self.output / "teste/index.pck").read_bytes())
        self.assertEqual(len(manifest["official_sha256"]), 5)

    def test_refuses_existing_destination(self):
        self.output.mkdir()
        with self.assertRaises(ValueError):
            compose.compose(self.preview, self.output)

    def test_refuses_changed_production(self):
        with patch.object(compose, "fetch", self.fetch):
            compose.compose(self.preview, self.output)
            self.official["index.pck"] = b"new main"
            with self.assertRaises(ValueError):
                compose.verify(self.output, True)

    def test_refuses_partial_export_and_unsafe_paths(self):
        (self.preview / "index.wasm").unlink()
        with self.assertRaises(ValueError):
            compose.compose(self.preview, self.output)
        config = {"executable": "../index", "fileSizes": {}}
        with self.assertRaises(ValueError):
            compose.dependencies("const GODOT_CONFIG = " + json.dumps(config) + ";")

if __name__ == "__main__":
    unittest.main(verbosity=2)
