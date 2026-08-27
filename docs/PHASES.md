# Pivot Point 3D — Build Phases

## Identity

Plans change. Find your next move.

Failed plans create information, not punishment.

## Phase 1 — Game Feel ✅

- [x] Godot 4 project
- [x] Third-person controller
- [x] Follow camera + collision avoidance
- [x] Interaction architecture
- [x] Attractive test environment + lighting
- [x] Art direction pack locked (see `ART_DIRECTION.md`)
- [ ] Playtest polish on desktop (human)

**Feel sandbox:** Boot → “Phase 1 Feel Test”, or open `scenes/main/test_environment.tscn`.

**Look target:** Oakhaven painterly low-fantasy. Greybox is temporary.

## Phase 2 — Base Hub ✅ (vertical slice)

Physical compound stations: Command, Map Room, Workshop, Locker, Recon, Comms, Archive.

Scene: `scenes/main/base_hub.tscn` (Oakhaven field post).

## Phase 3 — Supply Line World ✅ (vertical slice)

Kingsroad, destroyed bridge, Oakhaven village, eastern track, Highwatch Hold.

Scene: `scenes/main/supply_line.tscn`.

## Phase 4 — Pivot System ✅ (vertical slice)

World-first crossing break → parchment Pivot Event card → choices (baseline + optional kits) → After Action.

## Phase 5 — Crafting ✅ (vertical slice)

Six kits, 2-slot loadout, Workshop UI. Equipment adds choices only; never required.

## Phase 6 — Adaptive Director ✅ (vertical slice)

Local deterministic selection of pre-authored events. Default **OFF** on Mission Board. No LLM / API.

## Phase 7 — Polish (art publish pass)

- [x] Concept art wired into Boot / Leader Select / Mission Board / Pivot / After Action
- [x] Parchment UI styling + app icon
- [x] Oakhaven-leaning materials / translucent river
- [x] Export presets + `scripts/publish_export.sh` (see `docs/PUBLISH.md`)
- [ ] Full mesh art pass, audio, deeper accessibility, performance pass

## Phase 8 — Expansion

More missions, vehicles, Orbit / Rail — only after Supply Line is enjoyable.

## Hard exclusions (for now)

Guns, combat, health bars, enemies, crime, giant city, multiplayer, accounts, loot rarity, skill trees, LLM/API AI.

## Play loop

1. Boot → Choose Leader → Oakhaven Hub  
2. Workshop craft / equip (optional)  
3. Command / Map → Deploy Supply Line (Director optional)  
4. Walk Kingsroad → see destroyed bridge → resolve Pivot  
5. Continue to Highwatch → After Action → Hub  
