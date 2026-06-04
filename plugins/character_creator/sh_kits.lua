ix.kits = ix.kits or {}
ix.kits.stored = ix.kits.stored or {}

function ix.kits.Register(uniqueID, data)
    data.uniqueID = uniqueID
    ix.kits.stored[uniqueID] = data
end

function ix.kits.Get(uniqueID)
    return ix.kits.stored[uniqueID]
end

function ix.kits.GetAll()
    return ix.kits.stored
end

function ix.kits.GetForClass(classIndex)
    local kits = {}
    for k, v in pairs(ix.kits.stored) do
        if (v.class == classIndex) then
            kits[k] = v
        end
    end
    return kits
end

-- ==========================================
-- KITS DEL GRAN EJÉRCITO DE LA REPÚBLICA
-- ==========================================

-- Kits para la Clase: Asalto
ix.kits.Register("gar_assault_standard", {
    name = "Equipamiento de Asalto Estándar",
    description = "Incluye Rifle Blaster DC-15A, armadura de fase estándar y equipo de supervivencia básico.",
    faction = FACTION_GAR,
    class = CLASS_CLONE_ASSAULT,
    model = "models/player/combine_soldier.mdl", -- Cambia por tu modelo de Clon (Asalto)
    weapons = {"ix_smg1"}, -- Cambia por el id de tus armas de Star Wars
    items = {"ration"},
})

ix.kits.Register("gar_assault_cqb", {
    name = "Equipamiento de Combate Cercano (CQB)",
    description = "Incluye Blaster de repetición DC-15S, ideal para combate urbano e interiores.",
    faction = FACTION_GAR,
    class = CLASS_CLONE_ASSAULT,
    model = "models/player/combine_super_soldier.mdl", -- Cambia por tu modelo
    weapons = {"ix_shotgun", "ix_pistol"}, 
    items = {"health_vial"},
})

-- Kits para la Clase: Pesado
ix.kits.Register("gar_heavy_standard", {
    name = "Kit de Supresión Pesada",
    description = "Equipado con un Cañón Rotatorio Z-6 y armadura con placas de blindaje reforzadas.",
    faction = FACTION_GAR,
    class = CLASS_CLONE_HEAVY,
    model = "models/player/combine_soldier_prisonguard.mdl", -- Cambia por tu modelo de Clon Pesado
    weapons = {"ix_ar2"},
    items = {"ration"},
})
