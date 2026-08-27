# Publishing Pivot Point 3D

## Branch

Use `cursor/pivot-point-3d-art-publish-e657` (or successor) for art + export work.

## Requirements

- Godot **4.4.x**
- Export templates for 4.4.1 installed (`~/.local/share/godot/export_templates/4.4.1.stable/`)

## Export locally

From `pivot-point-3d/`:

```bash
chmod +x scripts/publish_export.sh
./scripts/publish_export.sh all    # linux + windows + web
./scripts/publish_export.sh linux
./scripts/publish_export.sh web
```

Outputs land in repo-adjacent `build/linux`, `build/windows`, `build/web`.

## What ships in this art pass

- Concept pack wired into Boot, Leader Select, Mission Board, Pivot cards, After Action
- Parchment / wood / gold UI styling
- App icon + parchment panel texture
- Oakhaven-leaning hub / river materials (still greybox geometry)

## Hosting notes

| Target | Notes |
|--------|--------|
| Desktop zip | Ship `build/linux` or `build/windows` |
| itch.io | Upload desktop zip and/or HTML5 from `build/web` |
| GitHub Pages / static host | Serve `build/web` (WASM + shared memory may need COOP/COEP headers for threads) |
| Vercel (web prototype) | Separate React app on `main` — needs `VERCEL_TOKEN` + egress |

## Version

`project.godot` → `0.3.0-art`
