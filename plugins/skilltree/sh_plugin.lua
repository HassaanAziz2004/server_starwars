local PLUGIN = PLUGIN

PLUGIN.name = "Skill Tree"
PLUGIN.author = "Arquitecto de Helix"
PLUGIN.description = "Sistema modular de árbol de habilidades."

-- =========================================================================
-- FORZAR CARGA DE ARCHIVOS (Soluciona el error de NetStream)
-- =========================================================================
ix.util.Include("cl_plugin.lua")
ix.util.Include("sv_plugin.lua")

-- Inicializamos la tabla global para registrar habilidades.
ix.skills = ix.skills or {}
ix.skills.list = ix.skills.list or {}

-- Función para registrar nuevas habilidades desde otros plugins o schemas.
function ix.skills:Register(uniqueID, data)
    self.list[uniqueID] = data
end

-- =========================================================================
-- REGISTRO EN BASE DE DATOS (Nativo de Helix)
-- =========================================================================

-- FIX: Eliminados los hooks manuales OnSet/OnGet. Helix gestiona la red 
-- automáticamente gracias a 'isLocal = true'.
ix.char.RegisterVar("skills", {
    field = "skills",
    fieldType = ix.type.text,
    default = {},
    isLocal = true, 
    bNoDisplay = true
})

-- Registramos los puntos de habilidad disponibles.
ix.char.RegisterVar("skillPoints", {
    field = "skill_points",
    fieldType = ix.type.number,
    default = 0,
    isLocal = true,
    bNoDisplay = true
})

-- =========================================================================
-- COMANDOS
-- =========================================================================

ix.command.Add("SkillTree", {
    description = "Abre tu terminal de habilidades.",
    OnRun = function(self, client)
        netstream.Start(client, "ixSkillOpenUI")
    end
})

-- =========================================================================
-- ZONA DE REGISTRO DE HABILIDADES
-- Añade todas tus nuevas habilidades aquí abajo.
-- =========================================================================

-- Habilidad 1: Vitalidad (La que ya teníamos)
ix.skills:Register("vitality", {
    name = "Vitalidad",
    description = "Aumenta tu salud máxima en 10 puntos por nivel.",
    maxLevel = 5,
    OnApply = function(client, level)
        client:SetMaxHealth(100 + (level * 10))
        client:SetHealth(client:GetMaxHealth())
    end
})

-- =========================================================================
-- PLANTILLA PARA NUEVAS HABILIDADES
-- Copia el bloque inferior, cambia el "id_unico" y personaliza los datos.
-- =========================================================================

-- Ejemplo 2: Habilidad que modifica daño físico (Ejemplo para un RPG)
ix.skills:Register("strength", {
    name = "Fuerza Bruta",
    description = "Aumenta el daño cuerpo a cuerpo de forma pasiva.",
    maxLevel = 3,
    
    -- El hook 'OnApply' se ejecuta cuando el jugador reaparece o mejora la habilidad.
    -- Úsalo para cambiar variables de Garry's Mod (velocidad, salud, armadura).
    OnApply = function(client, level)
        -- Por ejemplo, damos 10 de armadura inicial por cada nivel
        client:SetArmor(level * 10)
    end
})

-- Ejemplo 3: Habilidad pasiva de Rol (Ciberpunk/Sci-Fi)
ix.skills:Register("hacking", {
    name = "Rompehielos",
    description = "Permite interactuar con terminales de seguridad de nivel equivalente.",
    maxLevel = 4,
    
    -- NOTA IMPORTANTE: 
    -- Si la habilidad no cambia las estadísticas directas del jugador al instante,
    -- sino que simplemente sirve para comprobar si el jugador puede hacer algo o no,
    -- NO NECESITAS poner el "OnApply". Simplemente bórralo.
})