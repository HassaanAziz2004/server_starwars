-- ============================================================
-- CLASES DEL IMPERIO GALÁCTICO
-- Ruta: schema/classes/
-- Un archivo por clase, igual que sh_clone_assault.lua
-- ============================================================


-- ============================================================
-- CLASE: Stormtrooper
-- Ruta: schema/classes/sh_imp_stormtrooper.lua
-- ============================================================
-- CLASS.name        = "Stormtrooper"
-- CLASS.faction     = FACTION_EMPIRE
-- CLASS.description = "La columna vertebral del ejército imperial. Los Stormtroopers son soldados de élite entrenados para ejecutar las órdenes del Imperio sin dudar. Desplegados en todos los rincones de la galaxia."
-- CLASS.isDefault   = false
-- CLASS.image       = "materials/vgui/classes/imp_stormtrooper.png"
-- CLASS.models = {
--     "models/player/tu_stormtrooper.mdl",         -- Stormtrooper estándar
--     "models/player/tu_stormtrooper_sgt.mdl",     -- Sargento
--     "models/player/tu_stormtrooper_heavy.mdl",   -- Pesado
-- }
-- CLASS_IMP_STORMTROOPER = CLASS.index


-- ============================================================
-- ARCHIVO 1: schema/classes/sh_imp_stormtrooper.lua
-- ============================================================
CLASS.name        = "Stormtrooper"
CLASS.faction     = FACTION_EMPIRE
CLASS.description = "La columna vertebral del ejército imperial. Los Stormtroopers son soldados de élite entrenados para ejecutar las órdenes del Imperio sin dudar. Desplegados en todos los rincones de la galaxia para mantener el orden."
CLASS.isDefault   = false
CLASS.image       = "materials/vgui/classes/imp_stormtrooper.png"

-- Skins del Stormtrooper — añade tus modelos aquí
CLASS.models = {
    "models/player/combine_soldier.mdl",             -- Sustituir: Stormtrooper estándar (TK)
    "models/player/combine_super_soldier.mdl",       -- Sustituir: Stormtrooper de Asalto
    "models/player/combine_soldier_prisonguard.mdl", -- Sustituir: Stormtrooper Pesado
}

CLASS_IMP_STORMTROOPER = CLASS.index
