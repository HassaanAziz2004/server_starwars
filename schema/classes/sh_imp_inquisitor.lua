-- ============================================================
-- ARCHIVO: schema/classes/sh_imp_inquisitor.lua
-- ============================================================

CLASS.name        = "Inquisidor"
CLASS.faction     = FACTION_EMPIRE
CLASS.description = "Los Inquisidores son agentes de la Fuerza al servicio del Imperio y de Darth Vader. Antiguos Jedi caídos o sensibles a la Fuerza convertidos, su misión es cazar y eliminar a los supervivientes de la Orden Jedi. Temidos incluso dentro del propio Imperio."
CLASS.isDefault   = false
CLASS.image       = "materials/vgui/classes/imp_inquisitor.png"

-- Skins del Inquisidor — distintos inquisidores numerados
CLASS.models = {
    "models/player/combine_super_soldier.mdl",       -- Sustituir: Gran Inquisidor
    "models/player/combine_soldier.mdl",             -- Sustituir: Segundo Hermano
    "models/player/combine_soldier_prisonguard.mdl", -- Sustituir: Quinta Hermana
}

CLASS_IMP_INQUISITOR = CLASS.index
