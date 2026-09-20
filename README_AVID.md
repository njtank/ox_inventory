# Avid RP Inventory

This fork is the Avid RP inventory system built on ox_inventory.

Development branch: `feature/avid-inventory-v1`

## Design

- RP-first presentation
- Tarkov-style spatial item footprints
- spatial collision checks with fixed item orientation
- equipment slots for phone, radio, backpack, armor, primary, secondary, and melee
- backpack items are true ox_inventory containers
- spatial external storage for stashes, trunks, gloveboxes, evidence, dumpsters, and temp inventories
- spatial player-search workflow with explicit equipped-item confiscation
- owner-scoped institutional lockers for police, EMS, lawyers, and future jobs
- exact prison-property snapshot and restore
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


## Institutional lockers

Avid institutional lockers are normal spatial stashes with `owner = true`. Each character receives a separate persistent locker even when every member of the department uses the same locker id.

Built-in locker ids:

- `policelocker`
- `emslocker`
- `lawyerlocker`

Client resources can open them with:

```lua
exports.ox_inventory:openInstitutionLocker('police')
exports.ox_inventory:openInstitutionLocker('ems')
exports.ox_inventory:openInstitutionLocker('lawyer')
```

Additional jobs can register owner-scoped lockers server-side:

```lua
exports.ox_inventory:RegisterInstitutionLocker(
    'judge_locker',
    'Personal Judicial Locker',
    56,
    60000,
    { judge = 0 }
)
```

World targets and MLO coordinates should stay in the owning police/EMS/legal resource. The inventory resource owns persistence and access rules, not map placement.

## Evidence storage

Evidence storage uses spatial `policeevidence` inventories. Locker labels include the supplied case identifier.

```lua
exports.ox_inventory:openEvidenceLocker('25-0417')
```

Calling `openEvidenceLocker()` without a case id uses the normal evidence-number prompt. Existing police-group security is still enforced server-side.

## Prison property

Prison property is stored as an exact character snapshot in an owner-scoped database row. The snapshot includes normal ox metadata plus Avid grid and equipment state.

Server-side sentencing flow:

```lua
local success, reason = exports.ox_inventory:StorePrisonProperty(source)
```

The stored snapshot preserves:

- pocket grid positions
- phone/radio/equipment assignments
- equipped backpack identity
- the backpack container reference and its existing contents
- armor and weapon equipment assignments
- item metadata and durability

The active inventory is cleared and saved after the property snapshot succeeds.

The prison resource should register each valid property desk once from the server:

```lua
exports.ox_inventory:RegisterPrisonPropertyDesk(
    'bolingbroke_front_desk',
    vec3(0.0, 0.0, 0.0),
    2.0
)
```

Use the real prison desk coordinates in the prison resource. A client target at that desk can then call:

```lua
exports.ox_inventory:claimPrisonProperty()
```

The server verifies the player is physically near a registered property desk before returning anything.

For trusted server-side release flows, the prison resource can instead call:

```lua
exports.ox_inventory:ReturnPrisonProperty(source)
```

`HasPrisonProperty(source)` is also available server-side, with a client helper of the same name for UI/status checks.

On successful return, any prison-only items still carried are cleared first and the pre-sentence snapshot is restored. The restored inventory keeps its previous Avid layout and equipment assignments.
