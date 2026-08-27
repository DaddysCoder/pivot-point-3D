# Pivot Point 3D — Art Direction

Source concept pack (authoritative look target for the Godot product).

These images supersede the temporary greybox Frontier compound look from Phase 1 once art production begins. Phase 1 remains **game feel first**; this document locks visual identity and content mapping.

## Tone

Painterly low-fantasy / historical strategy.

- Ornate parchment + dark wood + gold UI frames
- Believable costumes and props (not cartoon, not photoreal)
- Adult strategic adventure — calm, readable, atmospheric
- World communicates change **before** UI text

Not: web cards, checkerboard grids, clinical UI, GTA crime fantasy, loot rarity chrome.

## Reference files

| File | Subject |
|------|---------|
| `art-reference/01-character-selection.jpg` | Leader select — six roles |
| `art-reference/02-world-map-oakhaven.jpg` | Regional map / first theatre |
| `art-reference/03-icon-sheet.jpg` | Location + resource + state icons |
| `art-reference/04-event-card-sheet.jpg` | Pivot Event card variants |
| `art-reference/05-event-bridge-destroyed-a.jpg` | Bridge Destroyed — narrative card |
| `art-reference/06-event-bridge-destroyed-b.jpg` | Bridge Destroyed — choice card |

## Leaders (character select)

UI title: **CHOOSE YOUR LEADER.**

| Role | Concept name | Visual anchors | Trait icons (from sheet) |
|------|--------------|----------------|--------------------------|
| Strategist | Marcus | Map, globe-staff, blue/gold tunic | Insight, tactics |
| Scout | Li | Bow, spyglass, cloak | Recon, pathfinding |
| Engineer | Elias | Blueprint, goggles, toolbelt | Craft, repair |
| Diplomat | Amina | Sealed letter, teal/gold formalwear | Ask / alliance |
| Historian | Elara | Journal, quill, instruments | Intel, archive |
| Builder | Kael | Mallet, timber, apron | Build, fortify |

**Implementation notes**

- Use these six as the default selectable roles for 3D (replacing the larger 8-role web list unless both are needed later).
- Present as adult operators/leaders (age presentation 21+) even if concept labels younger — matches the adult product brief.
- No giant RPG stat trees; roles bias available approaches / starting flavour only.
- Emblem + palette customisation still applies on top of role silhouette.

## First theatre — Oakhaven region

Map landmarks (mission geography must match 3D terrain later):

- **Ironpeak Mountains** — high passes, snow, dense pine
- **Oakhaven Village** — hub / base compound candidate
- **Oakhaven River** — primary crossing theatre
- **Highwatch Hold** — objective / stronghold
- **Weeping Marshes** — alternate biome / soft ground
- **The Kingsroad** — primary sealed road
- **Destroyed Bridge** — flagship Pivot visual (route unavailable)

Golden-hour lighting on the map matches Phase 1 lighting intent.

## Icon language

Use isometric parchment icons for map markers / briefings / HUD restraint:

**Places:** Fort, Village, Camp, Bridge, Destroyed Bridge, Mountain Pass, River Crossing, Roadblock  

**Economy / state:** Supplies (Materials), Information (Intel), Time, Danger (intensity), Ally, Unknown Event (Director-eligible)

Destroyed Bridge ↔ River Crossing is the core optional-equipment fork (Build kit / boat / ford / ask / reroute).

## Pivot Event cards

Card anatomy (UI target for in-mission presentation — still secondary to world-first change):

1. Header: `PIVOT POINT - EVENT CARD`
2. Title: e.g. `BRIDGE DESTROYED`
3. Illustration + small isometric map inset
4. Short status line (route blocked / conditions changed)
5. Choices with icons (not fail language)

### Bridge Destroyed — choice set (from cards)

Keep existing philosophy: failed plan → information, not punishment.

| Choice | Maps to action family | Notes |
|--------|----------------------|-------|
| Repair the bridge | Repair / Build | Cost / kit gated — optional |
| Ask the village for help | Ask | Diplomacy / radio / NPC |
| Find another route | Reroute / Recon | Always available baseline |
| Make my own plan | Adapt | Open / wildcard — never “wrong” |

Other sheet events to author later as pre-written Director candidates:

- Supplies Delayed
- Scout Missing
- Weather Changes
- New Information
- Ally Offers Help

## Mapping to systems

| System | Art implication |
|--------|-----------------|
| Base Hub | Oakhaven Village interiors/courtyard — walkable, not grid |
| Supply Line 3D | Kingsroad → destroyed bridge → Highwatch (or North Station renamed to regional fit) |
| Crafting kits | Visual props matching Engineer/Builder language |
| Adaptive Director | Selects cards like Bridge Destroyed; never generates prose |
| Mission Board | Parchment dossier + regional map, not web cards |

## Phase discipline

Do **not** rebuild the greybox into full fantasy art until Phase 1 movement/camera feel is signed off.

When art lands:

1. Replace operator capsule with role silhouettes
2. Rebuild compound as Oakhaven-adjacent field post / village yard
3. Build Kingsroad + destroyed bridge set piece for Supply Line
4. Hook icon sheet into map / brief / event UI
