# Chasm Web

Browser port of **Chasm: The Rift** using [PanzerChasm](https://github.com/Panzerschrek/Chasm-Reverse) (Emscripten + software renderer).

## Features

- Play in the browser over HTTP (WebGL 2 / software rasterizer)
- Loading bar for `PanzerChasm.data` (preloaded `CSM.BIN`)
- Saves in **IndexedDB** via Emscripten IDBFS (`/saves`)
- Software renderer on web (OpenGL renderer excluded from wasm build)

## Build

1. Place **`CSM.BIN`** in [`gamefiles/`](gamefiles/README.md) (not committed to Git).
2. Install [Emscripten](https://emscripten.org/) — e.g. `bloodweb\emsdk` on Desktop.
3. Run:

```powershell
.\scripts\build-web.ps1
```

Details: **[BUILD.md](BUILD.md)**

## Run locally

```powershell
cd web
python serve.py
```

→ http://127.0.0.1:8771/run.html (hard-refresh after rebuild: **Ctrl+F5**)

## Deploy

After building, upload **the contents of `web/`**:

`run.html`, `serve.py`, `PanzerChasm.js`, `PanzerChasm.wasm`, `PanzerChasm.data`, `shaders/`, `favicon.ico` (optional)

## Repository layout

| Path | Description |
|------|-------------|
| `web/` | HTML shell (`run.html`, `serve.py`) |
| `Chasm-Reverse/` | PanzerChasm engine with Emscripten patches |
| `gamefiles/` | Your `CSM.BIN` (local only) |
| `scripts/` | `build-web.ps1`, `build-web.sh`, `prepare-github.ps1` |
| `BUILD.md` | Full build instructions |

**Not in the repo:** `emsdk/`, `CSM.BIN`, built `PanzerChasm.data` (~62 MB).

## Engine notes

- **Not Build Engine** — Action Forms proprietary 3D (original Pascal, C++ reimplementation).
- Data: monolithic **`CSM.BIN`** (not GRP/RFF).
- PanzerChasm — GPL v3; game data is user-supplied.

## Web port author

[Carter54](https://github.com/Carter54git)
