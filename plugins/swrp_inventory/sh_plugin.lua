-- ============================================================
-- Plugin: SWRP Inventory
-- Autor: Antygravity
-- Descripción: UI de inventario estilo RPG para Star Wars RP
-- Framework: Helix (ix)
-- ============================================================

PLUGIN.name = "SWRP Inventory"
PLUGIN.author = "Antygravity"
PLUGIN.description = "UI de inventario estilo RPG para Star Wars RP"

-- Registrar nuevos tipos de inventario para equipamiento
ix.inventory.Register("equip_wep1", 4, 2, false)
ix.inventory.Register("equip_wep2", 4, 2, false)
ix.inventory.Register("equip_pistol", 2, 2, false)
ix.inventory.Register("equip_armor", 2, 2, false)
ix.inventory.Register("equip_bag", 2, 2, false)

local equipTypes = {
    "equip_wep1",
    "equip_wep2",
    "equip_pistol",
    "equip_armor",
    "equip_bag"
}

if SERVER then
    local function SyncEquippedBags(client, inv, characterID)
        if not inv then return end
        for _, item in pairs(inv:GetItems() or {}) do
            if item.isBag or item.base == "base_bags" then
                local bagInvID = item:GetData("id")
                if bagInvID then
                    local bagInv = ix.item.inventories[bagInvID]
                    if bagInv then
                        bagInv:AddReceiver(client)
                        bagInv:Sync(client)
                    else
                        ix.inventory.Restore(bagInvID, item.invWidth, item.invHeight, function(restoredBagInv)
                            if restoredBagInv and IsValid(client) then
                                restoredBagInv.vars.isBag = item.uniqueID
                                restoredBagInv:SetOwner(characterID)
                                restoredBagInv:AddReceiver(client)
                                restoredBagInv:Sync(client)
                            end
                        end)
                    end
                end
            end
        end
    end

    function PLUGIN:PlayerLoadedCharacter(client, character, lastChar)
        for _, invType in ipairs(equipTypes) do
            local invID = character:GetData(invType)
            if invID then
                local inv = ix.item.inventories[invID]
                if inv then
                    inv.vars.isBag = invType
                    local invData = ix.item.inventoryTypes[invType]
                    if invData and (inv.w ~= invData.w or inv.h ~= invData.h) then
                        inv:SetSize(invData.w, invData.h)
                    end
                    inv:SetOwner(character:GetID())
                    inv:AddReceiver(client)
                    inv:Sync(client)
                    SyncEquippedBags(client, inv, character:GetID())
                else
                    local invData = ix.item.inventoryTypes[invType]
                    local w, h = 1, 1
                    if invData then
                        w, h = invData.w, invData.h
                    end
                    ix.inventory.Restore(invID, w, h, function(restoredInv)
                        if restoredInv and IsValid(client) then
                            restoredInv.vars.isBag = invType
                            if invData and (restoredInv.w ~= invData.w or restoredInv.h ~= invData.h) then
                                restoredInv:SetSize(invData.w, invData.h)
                            end
                            restoredInv:SetOwner(character:GetID())
                            restoredInv:AddReceiver(client)
                            restoredInv:Sync(client)
                            SyncEquippedBags(client, restoredInv, character:GetID())
                        end
                    end)
                end
            else
                ix.inventory.New(character:GetID(), invType, function(inv)
                    character:SetData(invType, inv:GetID())
                    if IsValid(client) then
                        inv:AddReceiver(client)
                        inv:Sync(client)
                    end
                end)
            end
        end
    end

    function PLUGIN:OnItemTransferred(item, oldInv, newInv)
        if not newInv or not oldInv then return end
        
        local isEquipNew = newInv.vars and newInv.vars.isBag and string.sub(newInv.vars.isBag, 1, 5) == "equip"
        local isEquipOld = oldInv.vars and oldInv.vars.isBag and string.sub(oldInv.vars.isBag, 1, 5) == "equip"
        
        local client = item.player or newInv:GetOwner() or oldInv:GetOwner()
        if not IsValid(client) then return end

        if isEquipNew and not isEquipOld then
            -- Se movió al slot de equipamiento
            if item.isWeapon then
                -- Utilizar el sistema nativo de Helix para que actualice carryWeapons y ammo
                if item.Equip then
                    item:Equip(client, true, true)
                else
                    item:SetData("equip", true)
                    local wep = client:Give(item.class)
                    if IsValid(wep) then
                        client.carryWeapons = client.carryWeapons or {}
                        client.carryWeapons[item.weaponCategory or "sidearm"] = wep
                        wep.ixItem = item
                        wep:SetClip1(item:GetData("ammo", 0))
                        
                        -- Restaurar datos de accesorios (ArcCW y compatibles)
                        local attachments = item:GetData("attachments", {})
                        if not table.IsEmpty(attachments) then
                            timer.Simple(0.1, function()
                                if IsValid(wep) and wep.Attach then
                                    for slot, att in pairs(attachments) do
                                        wep:Attach(slot, att, true)
                                    end
                                    if wep.SendAllNetworkData then wep:SendAllNetworkData() end
                                end
                            end)
                        end
                    end
                    if item.WearPAC then item:WearPAC(client) end
                    if item.OnEquipWeapon then item:OnEquipWeapon(client, wep) end
                end
            elseif item.base == "base_armor" or item.category == "Armor" then
                item:SetData("equip", true)
                if item.functions and item.functions.Equip and item.functions.Equip.OnRun then
                    -- Run it silently
                    local oldPlayer = item.player
                    item.player = client
                    item.functions.Equip.OnRun(item)
                    item.player = oldPlayer
                end
            elseif item.isBag or item.base == "base_bags" then
                local bagInvID = item:GetData("id")
                if bagInvID then
                    local bagInv = ix.item.inventories[bagInvID]
                    if bagInv then
                        bagInv:AddReceiver(client)
                        bagInv:Sync(client)
                    else
                        ix.inventory.Restore(bagInvID, item.invWidth, item.invHeight, function(restoredBagInv)
                            if restoredBagInv and IsValid(client) then
                                restoredBagInv.vars.isBag = item.uniqueID
                                restoredBagInv:SetOwner(client:GetCharacter():GetID())
                                restoredBagInv:AddReceiver(client)
                                restoredBagInv:Sync(client)
                            end
                        end)
                    end
                end
            end
        elseif not isEquipNew and isEquipOld then
            -- Se retiró del slot de equipamiento
            if item.isWeapon then
                if item.Unequip then
                    item:Unequip(client, false, false)
                else
                    item:SetData("equip", false)
                    local wep = client:GetWeapon(item.class)
                    if IsValid(wep) then
                        item:SetData("ammo", wep:Clip1())
                        
                        -- Forzar el guardado de accesorios antes de eliminar (ArcCW y compatibles)
                        if wep.Attachments then
                            local atts = item:GetData("attachments", {})
                            local changed = false
                            for i, att in pairs(wep.Attachments) do
                                if att.Installed then
                                    atts[i] = att.Installed
                                    changed = true
                                end
                            end
                            if changed then
                                item:SetData("attachments", atts)
                            end
                        end
                    end
                    
                    client:StripWeapon(item.class)
                    if client.carryWeapons then
                        client.carryWeapons[item.weaponCategory or "sidearm"] = nil
                    end
                    if item.RemovePAC then item:RemovePAC(client) end
                    if item.OnUnequipWeapon then item:OnUnequipWeapon(client, wep) end
                end
            elseif item.base == "base_armor" or item.category == "Armor" then
                item:SetData("equip", false)
                if item.functions and item.functions.EquipUn and item.functions.EquipUn.OnRun then
                    local oldPlayer = item.player
                    item.player = client
                    item.functions.EquipUn.OnRun(item)
                    item.player = oldPlayer
                end
            end
        end
    end
end

function PLUGIN:CanTransferItem(item, oldInv, newInv)
    if not newInv then return end
    
    local invType = newInv.vars and newInv.vars.isBag
    if not invType then return end

    if invType == "equip_wep1" or invType == "equip_wep2" then
        if not item.isWeapon then return false end
        -- Restricción estricta: NO permitir pistolas/sidearms en los huecos principales (opcional, pero asegura uso de primarias)
        if item.weaponCategory and string.lower(item.weaponCategory) == "sidearm" then return false end
        return true
    elseif invType == "equip_pistol" then
        if not item.isWeapon then return false end
        -- Filtro estricto: SÓLO permite armas con categoría sidearm o pistola
        if not item.weaponCategory or string.lower(item.weaponCategory) ~= "sidearm" then return false end
        return true
    elseif invType == "equip_armor" then
        -- Flexibilidad en las bases de armadura y equipamiento
        if not (item.base == "base_armor" or item.category == "Armor" or item.base == "base_equipment" or item.isArmor or item.pacData) then 
            return false 
        end
        return true
    elseif invType == "equip_bag" then
        if not item.isBag and item.base ~= "base_bags" then return false end
        return true
    end
end

function PLUGIN:CanPlayerInteractItem(client, action, item)
    if action == "View" and (item.isBag or item.base == "base_bags") then
        local inv = ix.item.inventories[item.invID]
        if inv and inv.vars and inv.vars.isBag == "equip_bag" then
            return false
        end
    end
end

function PLUGIN:CanPlayerEquipItem(client, item)
    if item.isWeapon then
        local inv = ix.item.inventories[item.invID]
        -- Solo permitimos equipar internamente si el arma ya está dentro de un slot de equipamiento
        if inv and inv.vars and inv.vars.isBag and string.sub(inv.vars.isBag, 1, 5) == "equip" then
            return true
        end
        -- Oculta el botón "Equipar" en el menú de click derecho del inventario principal
        return false
    end
end

function PLUGIN:CanPlayerUnequipItem(client, item)
    if item.isWeapon then
        -- Oculta el botón "Desequipar" en el menú de click derecho. Para desequipar hay que sacarlo del slot manualmente.
        return false
    end
end

local function OverrideItems()
    for _, v in pairs(ix.item.list or {}) do
        if not v.bAntigravityOverride then
            if (v.isBag or v.base == "base_bags") then
                v.bAntigravityOverride = true
                
                local oldCanTransfer = v.CanTransfer
                v.CanTransfer = function(item, oldInv, newInv)
                    if newInv and newInv.vars and newInv.vars.isBag == "equip_bag" then
                        return true
                    end
                    if oldCanTransfer then return oldCanTransfer(item, oldInv, newInv) end
                    return true
                end

                if CLIENT and v.functions and v.functions.View then
                    local oldCanRun = v.functions.View.OnCanRun
                    v.functions.View.OnCanRun = function(item)
                        local inv = ix.item.inventories[item.invID]
                        if inv and inv.vars and inv.vars.isBag ~= "equip_bag" then
                            return false
                        end
                        if oldCanRun then return oldCanRun(item) end
                        return true
                    end
                end
            elseif v.isWeapon then
                v.bAntigravityOverride = true
                local oldCanTransfer = v.CanTransfer
                v.CanTransfer = function(item, oldInv, newInv)
                    -- Permitir sacar el arma del slot de equipamiento aunque esté "equipada"
                    if oldInv and oldInv.vars and oldInv.vars.isBag and string.sub(oldInv.vars.isBag, 1, 5) == "equip" then
                        return true
                    end
                    if oldCanTransfer then return oldCanTransfer(item, oldInv, newInv) end
                    return true
                end
            end
        end
    end
end
hook.Add("InitializedPlugins", "SWRP_OverrideItems", OverrideItems)
OverrideItems()

function PLUGIN:OnLoaded()
    OverrideItems()
    if SERVER then
        for _, client in ipairs(player.GetAll()) do
            local character = client:GetCharacter()
            if character then
                self:PlayerLoadedCharacter(client, character)
            end
        end
    end
end
