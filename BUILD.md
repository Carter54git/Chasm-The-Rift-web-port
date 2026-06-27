# Building Chasm Web

Windows (PowerShell). On Linux/macOS use [scripts/build-web.sh](scripts/build-web.sh).

## Requirements

1. **Git** and **CMake** 3.5+
2. **Emscripten SDK** — sibling `bloodweb\emsdk` or your own install:
   ```powershell
   cd C:\Users\user\Desktop\bloodweb
   git clone https://github.com/emscripten-core/emsdk.git emsdk
   cd emsdk
   .\emsdk install latest
   .\emsdk activate latest
   ```
3. **Python 3** — for `web/serve.py`
4. **Ninja** or **Make** — Emscripten cmake backend
5. **CSM.BIN** — in `gamefiles/` ([details](gamefiles/README.md))

## Quick build

```powershell
cd C:\Users\user\Desktop\chasmgit
.\scripts\build-web.ps1
```

Custom emsdk path:

```powershell
.\scripts\build-web.ps1 -EmsdkRoot C:\path\to\emsdk
```

## What the build does

1. Ensures `gamefiles\CSM.BIN` exists (optional auto-import from `AwesomeChasm-main\game\`)
2. Configures `Chasm-Reverse` with `emcmake cmake` → `build-wasm/`
3. Links with `--preload-file` for `CSM.BIN`, `PanzerChasm.cfg`, and `shaders/`
4. Copies `PanzerChasm.{js,wasm,data}` to `web/`
5. Copies `shaders/` and updates `buildTag` in `run.html`

## Run locally

**HTTP only** (not `file://`):

```powershell
cd web
python serve.py
```

Open: http://127.0.0.1:8771/run.html

Custom port: `$env:CHASM_PORT='8772'; python serve.py`

## Server deploy

Upload everything in `web/` after a successful build. The `.htaccess` in `web/` sets COOP/COEP headers if you use Apache.

## Troubleshooting

| Symptom | Likely cause |
|---------|----------------|
| `Engine aborted` / missing data | Built without `CSM.BIN` in `gamefiles/` |
| Black screen | Old cached `PanzerChasm.data` — hard refresh (Ctrl+F5) |
| `file://` does nothing | Use `python serve.py` |
| `emcc not in PATH` | Run `emsdk_env.ps1` or pass `-EmsdkRoot` |

## Patches vs upstream PanzerChasm

`Chasm-Reverse/` includes browser changes:

- `EMSCRIPTEN` block in `CMakeLists.txt` (MODULARIZE, IDBFS, preload, software-only sources)
- `PC_EMSCRIPTEN` guards in `host.cpp`, `system_window.cpp`, `main.cpp`, `sound/driver.cpp`, map drawers
- Multiplayer / desktop-only paths disabled on web

Based on [Panzerschrek/Chasm-Reverse](https://github.com/Panzerschrek/Chasm-Reverse).

## First-time GitHub publish

Run once before the initial commit (flattens nested `.git` dirs so the repo is self-contained):

```powershell
.\scripts\prepare-github.ps1
```

See [GITHUB_PUBLISH.txt](GITHUB_PUBLISH.txt).
