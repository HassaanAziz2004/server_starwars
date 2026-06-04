local PLUGIN = PLUGIN

PLUGIN.name = "Character Creator"
PLUGIN.author = "Antigravity"
PLUGIN.description = "A custom character creation system with Factions, Classes, and Kits."

ix.util.Include("sh_kits.lua")
ix.util.Include("cl_plugin.lua")
ix.util.Include("sv_plugin.lua")

-- Register the 'kit' character variable
ix.char.RegisterVar("kit", {
    field = "kit",
    fieldType = ix.type.string,
    default = "",
    bNoDisplay = true,
})
