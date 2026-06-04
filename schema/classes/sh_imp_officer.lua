-- ============================================================
-- ARCHIVO: schema/classes/sh_imp_officer.lua
-- ============================================================

CLASS.name        = "Oficial Imperial"
CLASS.faction     = FACTION_EMPIRE
CLASS.description = "Los Oficiales Imperiales son la cadena de mando del Imperio. Graduados de la Academia Imperial, coordinan las operaciones militares, gestionan recursos y mantienen la disciplina entre las tropas. Su autoridad es incuestionable."
CLASS.isDefault   = false
CLASS.image       = "materials/vgui/classes/imp_officer.png"

-- Skins del Oficial — rangos distintos
CLASS.models = {
    "models/player/combine_soldier.mdl",             -- Sustituir: Oficial de Campo (verde)
    "models/player/combine_super_soldier.mdl",       -- Sustituir: Comandante (negro)
    "models/player/combine_soldier_prisonguard.mdl", -- Sustituir: Gran Moff
}

CLASS_IMP_OFFICER = CLASS.index
