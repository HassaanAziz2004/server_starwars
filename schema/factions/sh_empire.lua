-- ============================================================
-- FACCIÓN: Imperio Galáctico
-- Ruta: schema/factions/sh_empire.lua
-- ============================================================

FACTION.name        = "Imperio Galáctico"
FACTION.description = "El Imperio Galáctico es la autoridad suprema de la galaxia. Fundado por el Emperador Palpatine tras la caída de la República, sus fuerzas militares mantienen el orden mediante la fuerza y el miedo. Servir al Imperio es servir a la paz galáctica."
FACTION.color       = Color(180, 180, 180)   -- Gris Imperial
FACTION.isDefault   = true

-- Modelo base de la facción (se sobreescribe por clase/kit)
-- Cambia por tus modelos de Stormtrooper
FACTION.models = {
    "models/player/combine_soldier.mdl",
}

-- Imagen de presentación en el creador
-- Coloca tu imagen en: materials/vgui/factions/empire.png
FACTION.image = "materials/vgui/factions/empire.png"

FACTION_EMPIRE = FACTION.index
