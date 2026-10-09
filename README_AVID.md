# Avid RP Inventory

This fork is the Avid RP inventory system built on ox_inventory.

Development branch: `feature/avid-inventory-v1`

## Design

- RP-first presentation
- Tarkov-style spatial item footprints
- spatial collision checks with fixed item orientation
- equipment slots for phone, radio, backpack, armor, primary, secondary, and melee
- semantic weapon hotkeys: 1 equips/holsters Primary, 2 equips/holsters Secondary
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

Evidence storage uses spatial `policeevidence` inventories. The canonical integration is:

```text
Avid player search
    -> avid_police report prompt
    -> avid_mdt evidence record / locker resolution
    -> ox_inventory case evidence storage
    -> avid_mdt custody log
```

The Avid search context exposes **Add to Evidence** for searched pockets, equipped gear, and the searched player's equipped backpack contents.

Case/report lockers open through:

```lua
exports.ox_inventory:openEvidenceLocker('CASE-26-00012')
```

Server-side police integrations use these inventory exports:

```lua
local ok, item = exports.ox_inventory:InspectEvidenceSource(officerSource, {
    target = targetServerId,
    sourceKind = 'searched', -- searched | searchedBackpack | searchedEquipment
    slot = slot,
    equipmentSlot = nil,
})

local stored, result = exports.ox_inventory:StoreEvidenceItem(officerSource, {
    target = targetServerId,
    sourceKind = 'searched',
    slot = slot,
    count = 1,
    lockerKey = 'CASE-26-00012',
    expectedName = item.name,
    metadata = evidenceMetadata,
})
```

`StoreEvidenceItem` revalidates police access, distance, the searched source, weight/grid capacity, equipped state, and the canonical evidence destination before moving anything. Equipped weapons are disarmed when fully seized. Backpack evidence keeps its real container reference and contents.

Evidence metadata can include `avidEvidence.lockerKey`, which the police integration uses to prevent an evidence item from being accidentally filed into a different case locker.

Existing police-group security remains enforced when opening `policeevidence` inventories.

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


## Simple physical shops

Avid's convenience-store retail flow now lives directly inside ox_inventory. The old `avid_logistics` resource is no longer required for these stores.

Current mapped stores:

- Strawberry 24/7
- David LTD
- Little Seoul LTD
- Downtown Vinewood 24/7

The flow is intentionally simple:

```text
Target shelf -> Take item -> item enters basket -> target clerk -> Checkout -> Cash or Card -> items enter spatial inventory
```

The basket is temporary and server-authoritative. Checkout validates:

- the player is at the correct clerk
- cash or bank balance
- inventory weight
- physical spatial grid room
- configured item validity

The shop targets prefer `avid_target` and retain ox_target-compatible fallbacks.

Remove/disable the old resource after updating:

```cfg
# remove:
ensure avid_logistics

# ox_inventory now owns the physical convenience shops
ensure ox_inventory
```

There is intentionally no stock economy, delivery simulation, store ownership, shipment system, or clerk combat logic in this implementation.

## Renamable backpacks

Any player currently carrying a backpack can right-click it and choose **Rename Backpack**.

The custom name is stored in:

```lua
metadata.avidBagName
```

It is not ownership-bound. Giving, dropping, storing, or transferring the backpack preserves the custom name and its persistent container. A future holder can rename it again.

Leaving the rename field blank restores the normal backpack name. Equipped backpacks also propagate the custom name to the Portable Storage panel.
