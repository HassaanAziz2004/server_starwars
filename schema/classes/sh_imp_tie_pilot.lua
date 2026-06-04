-- ============================================================
-- ARCHIVO: schema/classes/sh_imp_tie_pilot.lua
-- ============================================================

CLASS.name        = "Piloto TIE"
CLASS.faction     = FACTION_EMPIRE
CLASS.description = "Los Pilotos TIE son la élite aérea del Imperio. Entrenados en las academias imperiales para operar cazas TIE/ln, interceptores y bombarderos. Su traje hermético les permite sobrevivir en el vacío del espacio."
CLASS.isDefault   = false
CLASS.image       = "materials/vgui/classes/imp_tie_pilot.png"

-- Skins del Piloto TIE
CLASS.models = {
    "models/player/combine_soldier.mdl",         -- Sustituir: Piloto TIE estándar
    "models/player/combine_super_soldier.mdl",   -- Sustituir: Piloto de Interceptor
}

CLASS_IMP_TIE_PILOT = CLASS.index
