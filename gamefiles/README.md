# Chasm game data

The web build embeds **`CSM.BIN`** (~64 MB) into `PanzerChasm.data` at link time. This file is **not** included in the Git repository.

## Obtain CSM.BIN

From a licensed copy of **Chasm: The Rift** (GOG, Steam, or original CD install). Copy `CSM.BIN` into this folder.

`scripts/build-web.ps1` can auto-import from `Desktop\AwesomeChasm-main\game\CSM.BIN` if present.

## Config

On first build, `PanzerChasm.cfg` is copied from `Chasm-Reverse/default_PanzerChasm.cfg` if missing. You can edit it locally for resolution, controls, etc.

## Legal

`CSM.BIN` and all game assets remain the property of their rights holders. Supply files only from a copy you own.
