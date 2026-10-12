"""Package a Godot export for static hosts with small individual-file limits."""
import argparse
import gzip
import hashlib
import json
import shutil
from pathlib import Path

# Godot remains unchanged. Only the HTTP response for its WASM is decompressed.
WASM_LOADER = '''<script>
(() => {
  const nativeFetch = window.fetch.bind(window);
  window.fetch = async (input, init) => {
    const url = typeof input === 'string' ? input : (input.url || String(input));
    const parsed = new URL(url, location.href);
    if (!parsed.pathname.endsWith('/index.wasm')) return nativeFetch(input, init);
    if (typeof DecompressionStream === 'undefined') {
      throw new Error('Use uma versão atual do Chrome, Edge ou Firefox para jogar.');
    }
    parsed.pathname += '.gz';
    const response = await nativeFetch(parsed.href, init);
    if (!response.ok) throw new Error('Não foi possível carregar o jogo. Tente atualizar a página.');
    return new Response(response.body.pipeThrough(new DecompressionStream('gzip')), {
      status: 200, headers: {'Content-Type': 'application/wasm'}
    });
  };
})();
</script>
'''

def prepare(source, destination):
    source, destination = Path(source), Path(destination)
    if destination.exists():
        raise ValueError('Choose an empty export destination')
    shutil.copytree(source, destination)
    wasm = destination / 'index.wasm'
    raw = wasm.read_bytes()
    compressed = gzip.compress(raw, compresslevel=9, mtime=0)
    if gzip.decompress(compressed) != raw:
        raise ValueError('Compressed WebAssembly verification failed')
    (destination / 'index.wasm.gz').write_bytes(compressed)
    wasm.unlink()
    index = destination / 'index.html'
    html = index.read_text()
    marker = '<script src="index.js"></script>'
    if marker not in html:
        raise ValueError('Unexpected Godot shell')
    html = html.replace(marker, WASM_LOADER + marker)
    html = html.replace('<html lang="en">', '<html lang="pt-BR">').replace('<html>', '<html lang="pt-BR">')
    html = html.replace('Your browser does not support JavaScript.', 'Ative o JavaScript no navegador para jogar.')
    html = html.replace('Your browser does not support the canvas tag.', 'Use uma versão atual do navegador para jogar.')
    index.write_text(html)
    manifest = {'wasm_sha256': hashlib.sha256(raw).hexdigest(), 'wasm_bytes': len(raw),
                'compressed_bytes': len(compressed), 'pck_sha256': hashlib.sha256((source / 'index.pck').read_bytes()).hexdigest()}
    (destination / 'export-integrity.json').write_text(json.dumps(manifest, indent=2))
    print('Static preview ready. WASM is byte-identical after decompression:', manifest)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--source', default='build/preview')
    parser.add_argument('--destination', default='build/free-preview')
    args = parser.parse_args()
    prepare(args.source, args.destination)
