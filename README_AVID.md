# Avid RP Inventory

This fork is the Avid RP inventory system built on ox_inventory.

Development branch: `feature/avid-inventory-v1`

## Design

- RP-first presentation
- Tarkov-style spatial item footprints
- real rotation and collision checks
- equipment slots for phone, radio, backpack, armor, primary, secondary, and melee
- backpack items are true ox_inventory containers
- existing ox exports remain compatible

## Important architecture rule

Avid placement state is stored beside normal item metadata:

```lua
slot.avid = {
    version = 1,
    grid = { x = 1, y = 1, rotated = false },
    equipped = nil
}
```

It is intentionally not stored in `slot.metadata`, because ox uses metadata to determine stack identity.

## Build output

GitHub Actions builds `web/build` from the React source on the feature branch. The intended deployment target is a normal FiveM resource folder with no local frontend build step required.
