local Config = require 'modules.avid.config'

local Spatial = {}

local function state(item)
    item.avid = type(item.avid) == 'table' and item.avid or {}
    item.avid.version = Config.version
    return item.avid
end

local function cell(x, y)
    return ('%s:%s'):format(x, y)
end

function Spatial.GetLayout(inv)
    if not inv then return end

    if inv.type == 'player' then
        return table.clone(Config.playerGrid)
    end

    if inv.type == 'container' then
        local layout = Config.containerLayouts[inv.slots]
        return layout and table.clone(layout) or nil
    end

    return inv.avidLayout and table.clone(inv.avidLayout) or nil
end

function Spatial.GetItemSize(name, rotated)
    local size = Config.itemSizes[name] or Config.defaultItemSize
    local w, h = size.w or 1, size.h or 1

    if rotated then w, h = h, w end
    return { w = w, h = h }
end

local function occupancy(inv, layout, ignoreSlot)
    local out = {}

    for slot, item in pairs(inv.items or {}) do
        if item and item.name and tonumber(slot) ~= tonumber(ignoreSlot) then
            local avid = state(item)

            if not avid.equipped and avid.grid then
                local size = Spatial.GetItemSize(item.name, avid.grid.rotated == true)

                for y = avid.grid.y, avid.grid.y + size.h - 1 do
                    for x = avid.grid.x, avid.grid.x + size.w - 1 do
                        if x >= 1 and x <= layout.cols and y >= 1 and y <= layout.rows then
                            out[cell(x, y)] = tonumber(slot)
                        end
                    end
                end
            end
        end
    end

    return out
end

local function canPlace(layout, occupied, name, x, y, rotated)
    x, y = math.floor(tonumber(x) or 0), math.floor(tonumber(y) or 0)
    local size = Spatial.GetItemSize(name, rotated == true)

    if x < 1 or y < 1 or x + size.w - 1 > layout.cols or y + size.h - 1 > layout.rows then
        return false, 'out_of_bounds'
    end

    for gy = y, y + size.h - 1 do
        for gx = x, x + size.w - 1 do
            if occupied[cell(gx, gy)] then
                return false, 'occupied'
            end
        end
    end

    return true
end

local function occupy(occupied, name, placement)
    local size = Spatial.GetItemSize(name, placement.rotated == true)

    for y = placement.y, placement.y + size.h - 1 do
        for x = placement.x, placement.x + size.w - 1 do
            occupied[cell(x, y)] = true
        end
    end
end

local function firstFit(layout, occupied, name)
    local size = Spatial.GetItemSize(name, false)

    for y = 1, layout.rows - size.h + 1 do
        for x = 1, layout.cols - size.w + 1 do
            if canPlace(layout, occupied, name, x, y, false) then
                return { x = x, y = y, rotated = false }
            end
        end
    end
end

function Spatial.FirstFit(inv, name, ignoreSlot)
    local layout = Spatial.GetLayout(inv)
    if not layout then return end

    Spatial.Normalize(inv)
    return firstFit(layout, occupancy(inv, layout, ignoreSlot), name)
end

function Spatial.Normalize(inv)
    local layout = Spatial.GetLayout(inv)
    if not layout then return { changed = false, overflow = {} } end

    local changed, overflow, occupied = false, {}, {}

    for slot, item in pairs(inv.items or {}) do
        if item and item.name then
            local avid = state(item)

            -- Migration from the early prototype that placed UI state in metadata.
            if not avid.grid and item.metadata and item.metadata.avid and item.metadata.avid.grid then
                avid.grid = item.metadata.avid.grid
                item.metadata.avid = nil
                changed = true
            end

            if not avid.equipped and avid.grid then
                if avid.grid.rotated then
                    avid.grid.rotated = false
                    changed = true
                end

                local ok = canPlace(layout, occupied, item.name, avid.grid.x, avid.grid.y, false)

                if ok then
                    occupy(occupied, item.name, avid.grid)
                else
                    avid.grid = nil
                    changed = true
                end
            end
        end
    end

    for slot, item in pairs(inv.items or {}) do
        if item and item.name then
            local avid = state(item)

            if not avid.equipped and not avid.grid then
                local placement = firstFit(layout, occupied, item.name)

                if placement then
                    avid.grid = placement
                    occupy(occupied, item.name, placement)
                    changed = true
                else
                    overflow[#overflow + 1] = tonumber(slot)
                end
            end
        end
    end

    if changed then inv.changed = true end
    return { changed = changed, overflow = overflow }
end

function Spatial.CanPlace(inv, name, x, y, rotated, ignoreSlot)
    local layout = Spatial.GetLayout(inv)
    if not layout then return true end
    Spatial.Normalize(inv)
    return canPlace(layout, occupancy(inv, layout, ignoreSlot), name, x, y, rotated)
end

function Spatial.SetGrid(inv, slot, x, y, rotated)
    local layout = Spatial.GetLayout(inv)
    if not layout then return false, 'spatial_not_enabled' end

    local item = inv.items and inv.items[slot]
    if not item then return false, 'item_missing' end

    local avid = state(item)
    if avid.equipped then return false, 'item_equipped' end

    local ok, reason = canPlace(layout, occupancy(inv, layout, slot), item.name, x, y, rotated)
    if not ok then return false, reason end

    avid.grid = {
        x = math.floor(tonumber(x)),
        y = math.floor(tonumber(y)),
        rotated = rotated == true,
    }

    inv.changed = true
    return true
end

function Spatial.SetEquipped(inv, slot, equipmentSlot)
    local item = inv.items and inv.items[slot]
    if not item then return false, 'item_missing' end

    local avid = state(item)
    avid.equipped = equipmentSlot
    avid.grid = nil
    inv.changed = true
    return true
end

function Spatial.Unequip(inv, slot)
    local layout = Spatial.GetLayout(inv)
    local item = inv.items and inv.items[slot]
    if not layout or not item then return false, 'item_missing' end

    local placement = firstFit(layout, occupancy(inv, layout, slot), item.name)
    if not placement then return false, 'no_grid_space' end

    local avid = state(item)
    avid.equipped = nil
    avid.grid = placement
    inv.changed = true
    return true
end

function Spatial.UnequipToGrid(inv, slot, x, y, rotated)
    local layout = Spatial.GetLayout(inv)
    local item = inv.items and inv.items[slot]
    if not layout or not item then return false, 'item_missing' end

    local avid = state(item)
    local previousEquipment = avid.equipped
    avid.equipped = nil

    local ok, reason = canPlace(layout, occupancy(inv, layout, slot), item.name, x, y, rotated)

    if not ok then
        avid.equipped = previousEquipment
        return false, reason
    end

    avid.grid = {
        x = math.floor(tonumber(x)),
        y = math.floor(tonumber(y)),
        rotated = rotated == true,
    }

    inv.changed = true
    return true
end

function Spatial.CanFitRecords(inv, name, count)
    count = math.max(0, math.floor(tonumber(count) or 0))
    if count == 0 then return true end

    local layout = Spatial.GetLayout(inv)
    if not layout then return true end

    Spatial.Normalize(inv)
    local occupied = occupancy(inv, layout)

    for _ = 1, count do
        local placement = firstFit(layout, occupied, name)
        if not placement then return false end
        occupy(occupied, name, placement)
    end

    return true
end

function Spatial.CanReplace(inv, name, outgoingSlot)
    local layout = Spatial.GetLayout(inv)
    if not layout then return true end

    Spatial.Normalize(inv)
    local occupied = occupancy(inv, layout, outgoingSlot)
    return firstFit(layout, occupied, name) ~= nil
end

function Spatial.PlanTargets(inv, name, target)
    local layout = Spatial.GetLayout(inv)
    if not layout then return true, {} end

    Spatial.Normalize(inv)
    local occupied, plan = occupancy(inv, layout), {}

    local function add(slot)
        if inv.items[slot] then return true end

        local placement = firstFit(layout, occupied, name)
        if not placement then return false end

        plan[slot] = placement
        occupy(occupied, name, placement)
        return true
    end

    if type(target) == 'number' then
        if not add(target) then return false end
    elseif type(target) == 'table' then
        for i = 1, #target do
            if not add(target[i].slot) then return false end
        end
    end

    return true, plan
end

function Spatial.ApplyTarget(inv, slot, plan)
    local placement = plan and plan[slot]
    local item = inv.items and inv.items[slot]

    if not placement or not item then return end

    local avid = state(item)
    avid.grid = placement
    avid.equipped = nil
    inv.changed = true
end

function Spatial.ValidEquipment(name, slot)
    local rule = Config.equipment[slot]
    if not rule then return false end

    if rule.items and rule.items[name] then return true end

    if rule.weaponFallback and name:sub(1, 7) == 'WEAPON_' then
        if Config.equipment.secondary.items[name] or Config.equipment.melee.items[name] then
            return false
        end
        return true
    end

    return false
end

function Spatial.GetCompatibleEquipment(name)
    local slots = {}

    for key in pairs(Config.equipment) do
        if Spatial.ValidEquipment(name, key) then
            slots[#slots + 1] = key
        end
    end

    table.sort(slots)
    return slots
end

function Spatial.GetEquipmentConfig()
    local out = {}

    for key, value in pairs(Config.equipment) do
        out[key] = { label = value.label }
    end

    return out
end

return Spatial
