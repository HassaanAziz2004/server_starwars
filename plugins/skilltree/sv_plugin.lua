local PLUGIN = PLUGIN

netstream.Hook("ixSkillUpgrade", function(client, skillID)
    local character = client:GetCharacter()
    if (!character) then return end

    local skillData = ix.skills.list[skillID]
    if (!skillData) then return end 

    local currentPoints = character:GetSkillPoints() or 0
    local currentSkills = character:GetSkills() or {} 
    local currentLevel = currentSkills[skillID] or 0

    if (currentPoints <= 0) then
        client:NotifyLocalized("No tienes puntos de habilidad suficientes.")
        return
    end

    if (currentLevel >= skillData.maxLevel) then
        client:NotifyLocalized("Esta habilidad ya está al nivel máximo.")
        return
    end

    currentSkills[skillID] = currentLevel + 1
    
    character:SetSkills(currentSkills)
    character:SetSkillPoints(currentPoints - 1)

    if (skillData.OnApply) then
        skillData.OnApply(client, currentSkills[skillID])
    end

    client:Notify("Has mejorado " .. skillData.name .. " al nivel " .. currentSkills[skillID] .. ".")
end)

function PLUGIN:PostPlayerLoadout(client)
    local character = client:GetCharacter()
    if (!character) then return end

    local skills = character:GetSkills() or {} 
    for skillID, level in pairs(skills) do
        local skillData = ix.skills.list[skillID]
        if (skillData and skillData.OnApply) then
            skillData.OnApply(client, level)
        end
    end
end

-- =========================================================================
-- COMANDOS DE ADMINISTRADOR
-- =========================================================================

ix.command.Add("CharGiveSkillPoints", {
    description = "Da puntos de habilidad a un personaje.",
    adminOnly = true,
    arguments = {ix.type.character, ix.type.number},
    OnRun = function(self, client, target, amount)
        -- FIX: Validado contra un posible valor nulo de inicialización.
        target:SetSkillPoints((target:GetSkillPoints() or 0) + amount)
        client:Notify("Has dado " .. amount .. " puntos de habilidad a " .. target:GetName() .. ".")
    end
})