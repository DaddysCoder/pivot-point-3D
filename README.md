# Pivot Point 3D

**Plans change. Find your next move.**

> **Moving:** Canonical repository is now **[DaddysCoder/pivot-point-3D](https://github.com/DaddysCoder/pivot-point-3D)**.  
> See [`MOVED.md`](./MOVED.md) for migration status and push instructions.

Godot 4.4 · GDScript · Desktop-first third-person strategy/adventure.

This is a **new 3D product**, not a port of the React web prototype. The web app remains a mechanics/content reference only.

## Run

1. Open `project.godot` in Godot 4.4+
2. Press Play (F5) — starts at Boot
3. **Begin Campaign** → choose a leader → Oakhaven Hub → Workshop → Deploy Supply Line

Feel-only sandbox: Boot → **Phase 1 Feel Test**.

### Controls

| Action | Keyboard | Gamepad |
|--------|----------|---------|
| Move | WASD | Left stick |
| Sprint | Shift | R2 / RT |
| Look | Mouse | Right stick |
| Interact | E | A / Cross |
| Reset camera | V | — |
| Pause / free cursor | Esc | Start |

## Vertical slice (Phases 1–6)

| Phase | Status |
|-------|--------|
| Game feel (controller / camera / interact) | Done |
| Base Hub (Oakhaven stations) | Done |
| Supply Line world (Kingsroad / bridge / Highwatch) | Done |
| Pivot Event cards + After Action | Done |
| Crafting (6 kits, 2-slot loadout) | Done |
| Adaptive Director (local, optional, default off) | Done |

Art pass + publish tooling: [`docs/ART_DIRECTION.md`](./docs/ART_DIRECTION.md), [`docs/PUBLISH.md`](./docs/PUBLISH.md)

- Concept pack on Boot, Leader Select, Mission Board, Pivot cards, After Action
- Parchment / wood / gold UI; app icon
- Export: `./scripts/publish_export.sh all`

## Headless systems check

```bash
godot --headless --path . --scene res://scenes/tests/systems_test.tscn
```

## Product roadmap

See `docs/PHASES.md`.

## Note on repository layout

Lives under the Proof-and-path monorepo as `pivot-point-3d/` until a dedicated GitHub repository can be created.
