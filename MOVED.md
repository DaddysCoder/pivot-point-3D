# Pivot Point 3D — repository move

Canonical home is now:

**https://github.com/DaddysCoder/pivot-point-3D**

This folder in Proof-and-path was the incubation copy (Godot 4.4 vertical slice + art pass).

## Status

- Target repo exists and is empty.
- Cloud Agent push is **blocked** (Cursor GitHub App / token has write access only to `Proof-and-path`).
- A local migration commit is prepared; needs a credential that can push to `pivot-point-3D`.

## Option A — Grant agent access, then say “retry migrate”

1. Add `github.com/DaddysCoder/pivot-point-3D` to the Cloud Agent environment’s linked repos / repository dependencies, **or**
2. Install the Cursor GitHub App on `pivot-point-3D` with Contents read/write.

Then reply **retry migrate** in the agent chat.

## Option B — Push from your machine (one shot)

```bash
git clone https://github.com/DaddysCoder/Proof-and-path.git
cd Proof-and-path
git checkout cursor/pivot-point-3d-art-publish-e657

# Fresh repo from the Godot project root
rm -rf /tmp/pivot-point-3D-migrate
mkdir -p /tmp/pivot-point-3D-migrate
cp -a pivot-point-3d/. /tmp/pivot-point-3D-migrate/
rm -rf /tmp/pivot-point-3D-migrate/.godot
cd /tmp/pivot-point-3D-migrate

git init -b main
git add -A
git commit -m "Initial import: Pivot Point 3D from Proof-and-path"
git remote add origin https://github.com/DaddysCoder/pivot-point-3D.git
git push -u origin main
```

Open https://github.com/DaddysCoder/pivot-point-3D when the push finishes.

## After the move

In Proof-and-path we can delete or stub `pivot-point-3d/` so the web prototype stays the only product in that repo.
