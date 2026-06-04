-- ============================================================
-- Plugin: Character Creator — Kits del Imperio Galáctico
-- Ruta: plugins/character_creator/sh_kits.lua
-- ============================================================

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

-- ============================================================
-- KITS: STORMTROOPER
-- ============================================================

ix.kits.Register("imp_storm_standard", {
    name        = "Equipamiento TK Estándar",
    description = "Armadura de Stormtrooper de fase II con rifle blaster E-11. Dotación estándar para operaciones terrestres de infantería imperial.",
    faction     = FACTION_EMPIRE,
    class       = CLASS_IMP_STORMTROOPER,
    model       = "models/player/combine_soldier.mdl",          -- Sustituir por tu modelo Stormtrooper
    weapons     = {"weapon_blaster_e11"},                        -- Sustituir por el ID de tu arma
    items       = {"ration", "medikit"},
})

ix.kits.Register("imp_storm_heavy", {
    name        = "Equipamiento Stormtrooper Pesado",
    description = "Variante de asalto con armadura reforzada y cañón blaster T-21. Desplegado para romper líneas enemigas y suprimir puntos de resistencia.",
    faction     = FACTION_EMPIRE,
    class       = CLASS_IMP_STORMTROOPER,
    model       = "models/player/combine_super_soldier.mdl",    -- Sustituir por tu modelo Stormtrooper Pesado
    weapons     = {"weapon_blaster_t21"},
    items       = {"ration"},
})

ix.kits.Register("imp_storm_sniper", {
    name        = "Equipamiento Stormtrooper Explorador",
    description = "Scout Trooper equipado con blaster de precisión EC-17 y armadura ligera. Especialistas en reconocimiento, emboscadas y francotirismo.",
    faction     = FACTION_EMPIRE,
    class       = CLASS_IMP_STORMTROOPER,
    model       = "models/player/combine_soldier_prisonguard.mdl", -- Sustituir por tu modelo Scout Trooper
    weapons     = {"weapon_blaster_ec17"},
    items       = {"ration", "binoculars"},
})

-- ============================================================
-- KITS: PILOTO TIE
-- ============================================================

ix.kits.Register("imp_pilot_standard", {
    name        = "Equipamiento Piloto TIE/ln",
    description = "Traje de vuelo hermético estándar con blaster SE-14r. Los pilotos TIE son la primera línea de respuesta aérea del Imperio.",
    faction     = FACTION_EMPIRE,
    class       = CLASS_IMP_TIE_PILOT,
    model       = "models/player/combine_soldier.mdl",          -- Sustituir por tu modelo Piloto TIE
    weapons     = {"weapon_blaster_se14r"},
    items       = {"ration"},
})

ix.kits.Register("imp_pilot_interceptor", {
    name        = "Equipamiento Piloto de Interceptor",
    description = "Traje especializado para los cazas TIE/IN de alta velocidad. Estos pilotos de élite son seleccionados entre los mejores de la academia.",
    faction     = FACTION_EMPIRE,
    class       = CLASS_IMP_TIE_PILOT,
    model       = "models/player/combine_super_soldier.mdl",    -- Sustituir por tu modelo Piloto Interceptor
    weapons     = {"weapon_blaster_se14r", "weapon_thermal_det"},
    items       = {"ration"},
})

-- ============================================================
-- KITS: OFICIAL IMPERIAL
-- ============================================================

ix.kits.Register("imp_officer_field", {
    name        = "Oficial de Campo",
    description = "Uniforme de oficial de campo con blaster DH-17 y datapad táctico. Coordinan las operaciones sobre el terreno junto a las tropas.",
    faction     = FACTION_EMPIRE,
    class       = CLASS_IMP_OFFICER,
    model       = "models/player/combine_soldier.mdl",          -- Sustituir por tu modelo Oficial verde
    weapons     = {"weapon_blaster_dh17"},
    items       = {"ration", "datapad"},
})

ix.kits.Register("imp_officer_commander", {
    name        = "Comandante Imperial",
    description = "Uniforme negro de alto mando con blaster DL-44. Los Comandantes tienen autoridad directa sobre las guarniciones imperiales locales.",
    faction     = FACTION_EMPIRE,
    class       = CLASS_IMP_OFFICER,
    model       = "models/player/combine_super_soldier.mdl",    -- Sustituir por tu modelo Comandante negro
    weapons     = {"weapon_blaster_dl44"},
    items       = {"ration", "datapad", "rank_insignia"},
})

ix.kits.Register("imp_officer_moff", {
    name        = "Gran Moff",
    description = "El máximo rango regional del Imperio. Los Moffs gobiernan sectores enteros con plena autoridad militar y civil. Blaster de ceremonia y acceso a información clasificada.",
    faction     = FACTION_EMPIRE,
    class       = CLASS_IMP_OFFICER,
    model       = "models/player/combine_soldier_prisonguard.mdl", -- Sustituir por tu modelo Gran Moff
    weapons     = {"weapon_blaster_dl44"},
    items       = {"ration", "datapad", "rank_insignia", "holocron_imperial"},
})

-- ============================================================
-- KITS: INQUISIDOR
-- ============================================================

ix.kits.Register("imp_inq_grand", {
    name        = "Gran Inquisidor",
    description = "El líder de la Orden Inquisitorial. Empuña un sable de luz de disco giratorio de doble hoja. Su poder en la Fuerza y su brutalidad no tienen igual entre los servidores de Vader.",
    faction     = FACTION_EMPIRE,
    class       = CLASS_IMP_INQUISITOR,
    model       = "models/player/combine_super_soldier.mdl",    -- Sustituir por tu modelo Gran Inquisidor
    weapons     = {"weapon_lightsaber_inquisitor_grand"},        -- Sustituir por tu sable de luz
    items       = {"ration"},
})

ix.kits.Register("imp_inq_brother", {
    name        = "Inquisidor (Hermano)",
    description = "Agente inquisitorial designado como Hermano. Caza Jedi en las zonas de conflicto activo. Su sable de luz de hoja única le otorga mayor velocidad en combate.",
    faction     = FACTION_EMPIRE,
    class       = CLASS_IMP_INQUISITOR,
    model       = "models/player/combine_soldier.mdl",          -- Sustituir por tu modelo Inquisidor
    weapons     = {"weapon_lightsaber_inquisitor"},
    items       = {"ration"},
})

ix.kits.Register("imp_inq_sister", {
    name        = "Inquisidora (Hermana)",
    description = "Agente inquisitorial designada como Hermana. Especializada en infiltración y combate con sable de luz de doble hoja. Sus métodos son tan letales como sutiles.",
    faction     = FACTION_EMPIRE,
    class       = CLASS_IMP_INQUISITOR,
    model       = "models/player/combine_soldier_prisonguard.mdl", -- Sustituir por tu modelo Hermana
    weapons     = {"weapon_lightsaber_inquisitor_double"},
    items       = {"ration"},
})

-- ============================================================
-- KITS: ISB (INTELIGENCIA IMPERIAL)
-- ============================================================

ix.kits.Register("imp_isb_agent", {
    name        = "Agente ISB",
    description = "Uniforme blanco reglamentario de la Oficina de Seguridad Imperial. Equipado con blaster de precisión y dispositivos de escucha. Autoridad para interrogar y detener a cualquier ciudadano.",
    faction     = FACTION_EMPIRE,
    class       = CLASS_IMP_ISB,
    model       = "models/player/combine_soldier.mdl",          -- Sustituir por tu modelo ISB (uniforme blanco)
    weapons     = {"weapon_blaster_dh17"},
    items       = {"ration", "datapad", "binders", "scanner"},
})

ix.kits.Register("imp_isb_covert", {
    name        = "Agente Encubierto ISB",
    description = "Operativo de inteligencia sin uniforme. Actúa entre la población civil sin revelar su afiliación imperial. Sus métodos son discrecionales y sus órdenes, clasificadas.",
    faction     = FACTION_EMPIRE,
    class       = CLASS_IMP_ISB,
    model       = "models/player/combine_super_soldier.mdl",    -- Sustituir por tu modelo civil/encubierto
    weapons     = {"weapon_blaster_se14r"},
    items       = {"ration", "datapad", "fake_id", "scanner"},
})