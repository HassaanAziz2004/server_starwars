-- ============================================================
-- ARCHIVO: schema/classes/sh_imp_isb.lua
-- ============================================================

CLASS.name        = "Agente ISB"
CLASS.faction     = FACTION_EMPIRE
CLASS.description = "La Oficina de Seguridad Imperial (ISB) es el brazo de inteligencia y contrainteligencia del Imperio. Sus agentes operan en las sombras: infiltración, interrogatorios, vigilancia y eliminación de amenazas internas. Responden directamente al Emperador."
CLASS.isDefault   = false
CLASS.image       = "materials/vgui/classes/imp_isb.png"

-- Skins del ISB — distintos roles
CLASS.models = {
    "models/player/combine_soldier.mdl",             -- Sustituir: Agente ISB (uniforme blanco)
    "models/player/combine_super_soldier.mdl",       -- Sustituir: Agente encubierto (civil)
}

CLASS_IMP_ISB = CLASS.index
