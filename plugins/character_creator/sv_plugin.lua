local PLUGIN = PLUGIN

function PLUGIN:OnCharacterCreated(client, character)
    local kitID = character:GetKit()
    if (kitID and kitID != "") then
        local kitData = ix.kits.Get(kitID)
        if (kitData) then
            -- Assign model if the kit specifies one
            if (kitData.model) then
                character:SetModel(kitData.model)
            end
            
            -- Assign items to inventory
            if (kitData.items) then
                local inventory = character:GetInventory()
                if (inventory) then
                    for _, item in ipairs(kitData.items) do
                        inventory:Add(item)
                    end
                end
            end
        end
    end
end

function PLUGIN:PostPlayerLoadout(client)
    local character = client:GetCharacter()
    if (character) then
        local kitID = character:GetKit()
        if (kitID and kitID != "") then
            local kitData = ix.kits.Get(kitID)
            if (kitData and kitData.weapons) then
                for _, wep in ipairs(kitData.weapons) do
                    client:Give(wep)
                end
            end
        end
    end
end
