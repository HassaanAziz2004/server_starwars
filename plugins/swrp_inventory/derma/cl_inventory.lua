-- ============================================================
-- Archivo: cl_inventory.lua
-- Plugin: SWRP Inventory
-- Descripción: Diseño RPG de 3 columnas basado en el boceto del usuario
-- ============================================================

if SERVER then return end

print("[SWRP INVENTORY] Cargando cl_inventory.lua...")

local PLUGIN = PLUGIN

-- ============================================================
-- Configuración Global del Diseño (Fácil de modificar)
-- ============================================================
SWRP_CFG = {
    -- Colores Principales
    ColorBG          = Color(8, 12, 18, 150),       -- Fondo principal tipo terminal
    ColorSlot        = Color(12, 20, 30, 200),      -- Fondo de ranuras y paneles
    ColorBorder      = Color(30, 80, 120, 100),     -- Borde inactivo tecnológico
    ColorBorderHover = Color(0, 210, 255, 255),     -- Borde holográfico brillante al pasar mouse
    ColorAccent      = Color(0, 180, 255, 180),     -- Color de acento táctico (Cyan/Azul)
    ColorWhite       = Color(220, 240, 255, 255),   -- Texto principal
    ColorTextTitle   = Color(140, 200, 255, 255),   -- Títulos y cabeceras
    ColorCell        = Color(10, 20, 30, 120),      -- Fondo de celdas del inventario
    ColorCellBorder  = Color(0, 100, 150, 40),      -- Bordes de cuadrícula
    
    -- Opacidades y Efectos
    BlurIntensity    = 10,                          -- Intensidad del cristal esmerilado (solo panel base)
    ScanlineAlpha    = 50,                          -- Transparencia de las scanlines
    HoverAlphaBg     = 220,                         -- Fondo del menú lateral al estar activo
    
    -- Proporciones Responsivas
    ColWidthPct      = 0.16,                        -- Las columnas ocupan el 16% del ancho de pantalla
    MaxRightColPct   = 0.35,                        -- Ancho máximo para la columna derecha (35%)
    MinColWidth      = 280,                         -- Ancho mínimo absoluto en píxeles (para no romper en 4:3)
}

-- Alias locales para no romper la estructura inferior
local COLOR_BG = SWRP_CFG.ColorBG
local COLOR_SLOT = SWRP_CFG.ColorSlot
local COLOR_BORDER = SWRP_CFG.ColorBorder
local COLOR_BORDER_HOVER = SWRP_CFG.ColorBorderHover
local COLOR_ACCENT = SWRP_CFG.ColorAccent
local COLOR_WHITE = SWRP_CFG.ColorWhite
local COLOR_TEXT_TITLE = SWRP_CFG.ColorTextTitle
local COLOR_SLOT_CELL = SWRP_CFG.ColorCell
local COLOR_SLOT_CELL_BORDER = SWRP_CFG.ColorCellBorder

-- Creación de fuentes tácticas (usando tipografía nativa limpia)
surface.CreateFont("swrp_tech_title", {
    font = "Trebuchet MS",
    size = 14,
    weight = 800,
    antialias = true,
    shadow = true
})
surface.CreateFont("swrp_tech_small", {
    font = "Trebuchet MS",
    size = 12,
    weight = 400,
    antialias = true
})
surface.CreateFont("swrp_tech_large", {
    font = "Trebuchet MS",
    size = 24,
    weight = 800,
    antialias = true,
    shadow = true
})

local FONT_SMALL = "swrp_tech_small"
local FONT_NAME = "swrp_tech_large"
local FONT_TITLE = "swrp_tech_title"

local function SafeGetIcon(obj)
    if not obj then return nil end
    if type(obj.GetIcon) == "function" then return obj:GetIcon() end
    return obj.icon or obj.IconOverride
end

-- Función para crear slots con el estilo del boceto
local function CreateSlot(parent, x, y, w, h, label, icon, name)
    local p = vgui.Create("DPanel", parent)
    p:SetPos(x, y)
    p:SetSize(w, h)
    
    function p:Paint(sw, sh)
        local hover = self:IsHovered()
        draw.RoundedBox(4, 0, 0, sw, sh, hover and COLOR_BORDER_HOVER or COLOR_SLOT)
        surface.SetDrawColor(hover and COLOR_ACCENT or COLOR_BORDER)
        surface.DrawOutlinedRect(0, 0, sw, sh)
        
        if label then
            draw.SimpleText(label:upper(), FONT_SMALL, 8, 5, Color(150, 150, 150), TEXT_ALIGN_LEFT)
        end
        
        if icon and icon ~= "" then
            local mat = Material(icon)
            if mat and not mat:IsError() then
                surface.SetDrawColor(255, 255, 255, 255)
                surface.SetMaterial(mat)
                local size = math.min(sw, sh) * 0.5
                surface.DrawTexturedRect(sw/2 - size/2, sh/2 - size/2 - 5, size, size)
            end
        end
        
        if name and name ~= "" then
            draw.SimpleText(name, FONT_SMALL, sw/2, sh - 8, COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
        end
    end
    return p
end

-- Sobrescribir globalmente las celdas de ixInventory para que tengan el estilo futurista
local IX_INVENTORY = vgui.GetControlTable("ixInventory")
if IX_INVENTORY then
    local oldBuildSlots = IX_INVENTORY.BuildSlots
    function IX_INVENTORY:BuildSlots()
        if oldBuildSlots then
            oldBuildSlots(self)
        end
        for _, row in pairs(self.slots or {}) do
            for _, slot in pairs(row) do
                slot.Paint = function(s, sw, sh)
                    local inv = ix.item.inventories[self.invID]
                    local isEquip = inv and inv.vars and inv.vars.isBag and string.sub(inv.vars.isBag, 1, 5) == "equip"
                    
                    if isEquip then return end -- Ocultar la cuadrícula interna en las ranuras de equipamiento
                    
                    -- Fondo de la celda de datos
                    draw.RoundedBox(0, 2, 2, sw - 4, sh - 4, COLOR_SLOT_CELL)
                    
                    -- Borde sutil
                    surface.SetDrawColor(COLOR_SLOT_CELL_BORDER)
                    surface.DrawOutlinedRect(2, 2, sw - 4, sh - 4)
                    
                    -- Decoración técnica (pequeñas muescas)
                    surface.SetDrawColor(COLOR_ACCENT.r, COLOR_ACCENT.g, COLOR_ACCENT.b, 30)
                    surface.DrawRect(2, 2, 6, 2)
                    surface.DrawRect(2, 2, 2, 6)
                    surface.DrawRect(sw - 8, sh - 4, 6, 2)
                    surface.DrawRect(sw - 4, sh - 8, 2, 6)
                end
            end
        end
    end
end

-- Función para crear ranuras de equipamiento estilizadas
local function CreateEquipSlot(parent, x, y, w, h, label, invType)
    local char = LocalPlayer():GetCharacter()
    local invID = char:GetData(invType)

    -- Contenedor invisible para mantener el flujo del Dock(TOP)
    local wrap = vgui.Create("DPanel", parent)
    wrap:SetSize(w, h)
    wrap.Paint = function() end

    -- El panel visual real
    local p = vgui.Create("DPanel", wrap)
    p:SetSize(w, h)
    p:CenterHorizontal()
    p.bNoBackgroundBlur = true

    function p:Paint(sw, sh)
        local hover = self:IsHovered()
        local hasItem = false
        if invID then
            local inv = ix.item.inventories[invID]
            if inv and table.Count(inv:GetItems()) > 0 then hasItem = true end
        end

        -- Fondo del slot con ligero degradado
        surface.SetDrawColor(COLOR_SLOT)
        surface.DrawRect(0, 0, sw, sh)
        
        -- Scanlines sutiles para estética táctica
        surface.SetDrawColor(0, 0, 0, 50)
        for i = 0, sh, 4 do
            surface.DrawLine(0, i, sw, i)
        end

        -- Cabecera oscura tecnológica
        surface.SetDrawColor(0, 0, 0, 220)
        surface.DrawRect(0, 0, sw, 22)
        
        -- Texto de la cabecera (Mayúsculas, espaciado simulado)
        draw.SimpleText(label:upper(), FONT_TITLE, sw / 2, 11, COLOR_TEXT_TITLE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        -- Decoración de texto "Aurebesh/Data" en las esquinas
        local sysName = string.Replace(invType:upper(), "EQUIP_", "")
        draw.SimpleText("SYS."..sysName, FONT_SMALL, 4, sh - 14, Color(255,255,255, 15), TEXT_ALIGN_LEFT)
        draw.SimpleText("OP.RDY", FONT_SMALL, sw - 4, 4, Color(255,255,255, 15), TEXT_ALIGN_RIGHT)

        -- Línea divisoria bajo cabecera (Holográfica)
        local lc = hasItem and COLOR_ACCENT or COLOR_BORDER
        surface.SetDrawColor(lc.r, lc.g, lc.b, hasItem and 255 or 100)
        surface.DrawLine(0, 22, sw, 22)
        if hasItem then
            surface.SetDrawColor(lc.r, lc.g, lc.b, 50)
            surface.DrawLine(0, 23, sw, 23)
        end

        -- Esquinas estilo Targeting Computer (HUD Star Wars)
        local cc = hasItem and COLOR_ACCENT or COLOR_BORDER
        if hover then cc = COLOR_BORDER_HOVER end
        surface.SetDrawColor(cc)
        local cl = 15 -- Longitud de la esquina
        local th = 2  -- Grosor
        
        -- Arriba Izquierda
        surface.DrawRect(0, 0, cl, th)
        surface.DrawRect(0, 0, th, cl)
        -- Arriba Derecha
        surface.DrawRect(sw - cl, 0, cl, th)
        surface.DrawRect(sw - th, 0, th, cl)
        -- Abajo Izquierda
        surface.DrawRect(0, sh - th, cl, th)
        surface.DrawRect(0, sh - cl, th, cl)
        -- Abajo Derecha
        surface.DrawRect(sw - cl, sh - th, cl, th)
        surface.DrawRect(sw - th, sh - cl, th, cl)

        -- Borde completo en hover
        if hover then
            surface.SetDrawColor(COLOR_BORDER_HOVER.r, COLOR_BORDER_HOVER.g, COLOR_BORDER_HOVER.b, 50)
            surface.DrawOutlinedRect(0, 0, sw, sh)
            surface.SetDrawColor(COLOR_BORDER_HOVER.r, COLOR_BORDER_HOVER.g, COLOR_BORDER_HOVER.b, 20)
            surface.DrawRect(0, 0, sw, sh)
        else
            -- Borde muy sutil si no hay hover
            surface.SetDrawColor(COLOR_BORDER.r, COLOR_BORDER.g, COLOR_BORDER.b, 40)
            surface.DrawOutlinedRect(0, 0, sw, sh)
        end
    end

    if invID then
        local inv = ix.item.inventories[invID]
        if inv then
            local invPanel = p:Add("ixInventory")

            local oldInv1 = ix.gui.inv1
            ix.gui.inv1 = nil
            invPanel:SetInventory(inv)
            ix.gui.inv1 = oldInv1

            invPanel:SetTitle(nil)
            invPanel.bNoBackgroundBlur = true
            invPanel:SetDraggable(false)
            invPanel:SetSizable(false)
            invPanel.Paint = function() end

            local oldOnRemove = invPanel.OnRemove
            invPanel.OnRemove = function(this)
                if ix.gui["inv" .. invID] == this then ix.gui["inv" .. invID] = nil end
                if isfunction(oldOnRemove) then oldOnRemove(this) end
            end
            ix.gui["inv" .. invID] = invPanel

            invPanel.ReceiveDrop = function(this, panels, bDropped, menuIndex, dropX, dropY)
                local panel = panels[1]
                if not IsValid(panel) then this.previewPanel = nil return end
                if bDropped then
                    local inventory = ix.item.inventories[this.invID]
                    if inventory and panel.OnDrop then panel:OnDrop(true, this, inventory, 1, 1) end
                    this.previewPanel = nil
                else
                    this.previewPanel = panel
                    this.previewX = 1
                    this.previewY = 1
                end
            end

            -- Ocultar cuadrículas internas del slot de equipamiento
            for _, row in pairs(invPanel.slots or {}) do
                for _, slot in pairs(row) do
                    slot.Paint = function() end
                end
            end

            p.Think = function(self)
                if not IsValid(invPanel) or not IsValid(wrap) then return end
                
                local hasItem = false
                local iconW, iconH = 0, 0
                local iconPanel = nil
                
                for _, child in ipairs(invPanel:GetChildren()) do
                    if child.GetItemID or child.itemTable or (child:GetClassName() == "ixItemIcon") then
                        hasItem = true
                        iconPanel = child
                        local cw, ch = child:GetSize()
                        if cw > 0 and ch > 0 then
                            iconW = cw
                            iconH = ch
                        end
                        break
                    end
                end
                
                -- El tamaño de la caja será al menos el tamaño por defecto (w, h)
                -- pero si el arma es enorme, la caja crecerá para que quepa (math.max)
                local targetW = math.max(w, iconW)
                local targetH = math.max(h, iconH + 22)
                
                if self:GetWide() ~= targetW or self:GetTall() ~= targetH then
                    self:SetSize(targetW, targetH)
                    self:CenterHorizontal()
                    wrap:SetSize(targetW, targetH)
                    
                    local par = wrap:GetParent()
                    if IsValid(par) then par:InvalidateLayout() end
                end
                
                -- Centrar visualmente el item dentro del recuadro con matemáticas exactas
                if hasItem and iconW > 0 and IsValid(iconPanel) then
                    local ix, iy = iconPanel:GetPos()
                    
                    -- Aseguramos que invPanel sea lo suficientemente grande para no cortar el item (offset + tamaño)
                    invPanel:SetSize(ix + iconW, iy + iconH)
                    
                    -- Centro geométrico de la caja visual (ignorando cabecera para Y)
                    local CX = targetW / 2
                    local CY = 22 + (targetH - 22) / 2
                    
                    -- Centro geométrico del item relativo a invPanel
                    local IX = ix + (iconW / 2)
                    local IY = iy + (iconH / 2)
                    
                    -- Alineamos los centros
                    invPanel:SetPos(CX - IX, CY - IY)
                else
                    invPanel:SetSize(targetW, targetH - 22)
                    invPanel:SetPos(0, 22)
                end
            end
        end
    end

    return wrap
end

-- Integración en el menú TAB

hook.Add("CreateMenuButtons", "ixInventory", function(tabs)
    -- Sobrescribimos la pestaña "inv" por defecto de Helix con nuestra propia interfaz
    tabs["inv"] = {
        bDefault = true,
        OnCanRun = function() return IsValid(LocalPlayer():GetCharacter()) end,
        Create = function(info, container)
            local lp = LocalPlayer()
            local char = lp:GetCharacter()
            local scroll, canvas
            
            -- Contenedor principal con Glassmorphism
            local main = vgui.Create("DPanel", container)
            main:Dock(FILL)
            main:DockMargin(40, 40, 40, 40)
            main.bNoBackgroundBlur = true
            
            main.Paint = function(s, sw, sh)
                -- Aplicar difuminado real (Glassmorphism intenso)
                ix.util.DrawBlur(s, 10)
                
                -- Capa oscura translúcida (Fondo táctico)
                draw.RoundedBox(0, 0, 0, sw, sh, COLOR_BG)
                
                -- Rejilla/Grid tecnológico sutil de fondo
                surface.SetDrawColor(COLOR_BORDER.r, COLOR_BORDER.g, COLOR_BORDER.b, 10)
                for i = 0, sw, 64 do surface.DrawLine(i, 0, i, sh) end
                for i = 0, sh, 64 do surface.DrawLine(0, i, sw, i) end
                
                -- Borde holográfico perimetral
                surface.SetDrawColor(COLOR_ACCENT.r, COLOR_ACCENT.g, COLOR_ACCENT.b, 100)
                surface.DrawOutlinedRect(0, 0, sw, sh)
                surface.SetDrawColor(COLOR_ACCENT.r, COLOR_ACCENT.g, COLOR_ACCENT.b, 40)
                surface.DrawOutlinedRect(1, 1, sw - 2, sh - 2)
                
                -- Esquinas perimetrales pesadas
                surface.SetDrawColor(COLOR_ACCENT)
                local cl, th = 30, 4
                surface.DrawRect(0, 0, cl, th) surface.DrawRect(0, 0, th, cl)
                surface.DrawRect(sw-cl, 0, cl, th) surface.DrawRect(sw-th, 0, th, cl)
                surface.DrawRect(0, sh-th, cl, th) surface.DrawRect(0, sh-cl, th, cl)
                surface.DrawRect(sw-cl, sh-th, cl, th) surface.DrawRect(sw-th, sh-cl, th, cl)
            end


            local lastBagID = nil
            main.Think = function(self)
                -- Evitar ejecutar antes de que toda la creación de la UI haya finalizado
                if not self.bInitialized then
                    return
                end

                local menuAlpha = IsValid(ix.gui.menu) and ix.gui.menu:GetAlpha() or 255
                
                -- Lógica de Mochila Automática
                local b_invID = char:GetData("equip_bag")
                local currentBag = nil
                local currentBagItem = nil
                
                if b_invID then
                    local b_inv = ix.item.inventories[b_invID]
                    if b_inv then
                        for _, v in pairs(b_inv:GetItems()) do
                            if v.isBag or v.base == "base_bags" then
                                local bagInvID = v:GetData("id")
                                if bagInvID and ix.item.inventories[bagInvID] then
                                    currentBag = bagInvID
                                    currentBagItem = v
                                    break
                                end
                            end
                        end
                    end
                end

                if currentBag ~= lastBagID then
                    if lastBagID then
                        local pnl = ix.gui["inv"..lastBagID]
                        if IsValid(pnl) then 
                            pnl:Remove() 
                            timer.Simple(0.1, function()
                                if IsValid(canvas) then
                                    canvas:InvalidateLayout(true)
                                    canvas:Layout()
                                end
                                if IsValid(scroll) then
                                    scroll:InvalidateLayout(true)
                                end
                            end)
                        end
                    end
                    lastBagID = currentBag
                    self.bCreatingBag = false
                end

                if currentBag and currentBagItem then
                    local pnl = ix.gui["inv" .. currentBag]
                    if IsValid(pnl) then
                        if pnl:GetParent() ~= canvas then
                            pnl:SetVisible(false)
                            pnl:Remove()
                            self.bCreatingBag = false
                        else
                            self.bCreatingBag = true
                        end
                    end

                    if not IsValid(pnl) and not self.bCreatingBag then
                        self.bCreatingBag = true
                        
                        -- Retraso de seguridad para que el Canvas nativo termine de inicializarse
                        timer.Simple(0.2, function()
                            if not IsValid(self) or not currentBagItem then return end
                            
                            -- Doble comprobación por si el usuario hizo clic manualmente durante este retraso
                            if IsValid(ix.gui["inv" .. currentBag]) then return end
                            
                            if currentBagItem.functions and currentBagItem.functions.View then
                                currentBagItem.functions.View.OnClick(currentBagItem)
                                
                                timer.Simple(0.1, function()
                                    if IsValid(canvas) then
                                        canvas:InvalidateLayout(true)
                                        canvas:Layout()
                                    end
                                    if IsValid(scroll) then
                                        scroll:InvalidateLayout(true)
                                    end
                                    if IsValid(self) and not IsValid(ix.gui["inv" .. currentBag]) then
                                        self.bCreatingBag = false
                                    end
                                end)
                            end
                        end)
                    end
                end
            end

            -- Limpieza al cerrar/eliminar el panel del menú
            main.OnRemove = function(self)
                if lastBagID then
                    local pnl = ix.gui["inv" .. lastBagID]
                    if IsValid(pnl) then
                        pnl:Remove()
                    end
                    ix.gui["inv" .. lastBagID] = nil
                end
            end
            
            -- Definimos las dimensiones dinámicas y responsivas
            local sw = ScrW()
            local colW = math.max(SWRP_CFG.MinColWidth, sw * SWRP_CFG.ColWidthPct)
            local maxRightW = sw * SWRP_CFG.MaxRightColPct
            local rightW = colW + 40 -- La columna derecha suele necesitar más espacio
            local inventory = char:GetInventory()
            if inventory then
                local invW = inventory:GetSize()
                -- Nos aseguramos de que el panel derecho pueda acomodar al menos el ancho de la cuadrícula si es muy grande
                rightW = math.max(rightW, (invW * 64) + 32) 
            end
            
            local rightW_clamped = math.min(rightW, maxRightW)
            
            -- --- COLUMNA IZQUIERDA (Armas y Mochila) ---
            local left = vgui.Create("DPanel", main)
            left:SetWide(colW)
            left:Dock(LEFT)
            left:DockMargin(15, 15, 15, 15)
            left.bNoBackgroundBlur = true
            left.Paint = function() end

            -- Apilamiento dinámico automático con Dock
            local arma1 = CreateEquipSlot(left, 0, 0, colW, 160, "Arma Primaria", "equip_wep1")
            arma1:Dock(TOP)
            arma1:DockMargin(0, 0, 0, 10)

            local arma2 = CreateEquipSlot(left, 0, 0, colW, 160, "Arma Secundaria", "equip_wep2")
            arma2:Dock(TOP)
            arma2:DockMargin(0, 0, 0, 10)

            local bottomRow = vgui.Create("DPanel", left)
            bottomRow:Dock(TOP)
            bottomRow:SetTall(160)
            bottomRow.Paint = function() end

            local smallW = colW / 2 - 5
            local pistola = CreateEquipSlot(bottomRow, 0, 0, smallW, 160, "Pistola",  "equip_pistol")
            pistola:Dock(LEFT)

            local mochila = CreateEquipSlot(bottomRow, 0, 0, smallW, 160, "Mochila",  "equip_bag")
            mochila:Dock(RIGHT)

            -- --- COLUMNA CENTRAL (Personaje) ---
            local center = vgui.Create("DPanel", main)
            center:Dock(FILL)
            center:DockMargin(0, 15, 0, 15)
            center.bNoBackgroundBlur = true


            
            center.Paint = function(s, sw, sh)
                local alpha = IsValid(ix.gui.menu) and (ix.gui.menu:GetAlpha() / 255) or 1
                surface.SetAlphaMultiplier(alpha)
                
                -- Nombre con efecto HUD sombra
                draw.SimpleText(char:GetName():upper(), FONT_NAME, sw/2 + 1, 13, Color(0, 0, 0, 180), TEXT_ALIGN_CENTER)
                draw.SimpleText(char:GetName():upper(), FONT_NAME, sw/2, 12, COLOR_WHITE, TEXT_ALIGN_CENTER)
                
                -- Facción
                local f = ix.faction.Get(char:GetFaction())
                if f then
                    draw.SimpleText(f.name:upper(), FONT_SMALL, sw/2 + 1, 39, Color(0, 0, 0, 180), TEXT_ALIGN_CENTER)
                    draw.SimpleText(f.name:upper(), FONT_SMALL, sw/2, 38, COLOR_ACCENT, TEXT_ALIGN_CENTER)
                end
                
                surface.SetAlphaMultiplier(1)
            end

            center.PaintOver = function(s, sw, sh)
                local alpha = IsValid(ix.gui.menu) and (ix.gui.menu:GetAlpha() / 255) or 1
                surface.SetAlphaMultiplier(alpha)
                
                -- SOLUCIÓN: Obtenemos los valores. Leemos GetNetVar por si estás 
                -- mandando la vida/escudo modificado desde el servidor.
                local hp = lp:Health()
                local maxHp = lp:GetNetVar("maxHealth", lp:GetMaxHealth())
                if maxHp < 1 then maxHp = 100 end

                local arm = lp:Armor()
                local maxArm = lp:GetNetVar("maxArmor", lp.GetMaxArmor and lp:GetMaxArmor() or 100)
                if maxArm < 1 then maxArm = 100 end

                -- Parche de seguridad visual: Si la vida/armadura actual supera a la máxima conocida 
                -- por el cliente por falta de sincronización de GMod, forzamos a que el máximo se adapte.
                if maxHp < hp then maxHp = hp end
                if maxArm < arm then maxArm = arm end
                
                local barWidth = sw - 120
                local xOffset = 60
                
                -- ==============================================
                -- Barra de SALUD (Medical Monitor)
                -- ==============================================
                local yPos = sh - 90
                local hpRatio = math.Clamp(hp/maxHp, 0, 1)
                local hpColor = hpRatio < 0.3 and Color(255, 50, 50) or Color(100, 255, 150)
                
                -- Textos Holográficos
                draw.SimpleText("SYS.MED // VITALS", FONT_SMALL, xOffset, yPos - 18, COLOR_TEXT_TITLE, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                draw.SimpleText(math.Round(hp) .. " / " .. maxHp, FONT_TITLE, xOffset + barWidth, yPos - 18, hpColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
                
                -- Fondo de la barra
                surface.SetDrawColor(0, 0, 0, 150)
                surface.DrawRect(xOffset, yPos, barWidth, 8)
                
                -- Borde luminoso de la barra
                surface.SetDrawColor(COLOR_BORDER)
                surface.DrawOutlinedRect(xOffset - 1, yPos - 1, barWidth + 2, 10)
                
                -- Relleno de la barra (con efecto neón)
                surface.SetDrawColor(hpColor.r, hpColor.g, hpColor.b, 200)
                surface.DrawRect(xOffset, yPos, barWidth * hpRatio, 8)
                
                -- Resplandor interior (Neon)
                surface.SetDrawColor(hpColor.r, hpColor.g, hpColor.b, 50)
                for g = 1, 3 do
                    surface.DrawOutlinedRect(xOffset - g, yPos - g, (barWidth * hpRatio) + (g*2), 8 + (g*2))
                end

                -- Segmentación (Ticks médicos)
                surface.SetDrawColor(0, 0, 0, 200)
                for i = 1, 10 do
                    local tickX = xOffset + (barWidth / 10) * i
                    surface.DrawRect(tickX - 1, yPos, 2, 8)
                end
                
                -- Efecto crítico de pulso
                if hpRatio < 0.3 then
                    surface.SetDrawColor(255, 0, 0, math.abs(math.sin(CurTime() * 8)) * 100)
                    surface.DrawRect(xOffset, yPos, barWidth, 8)
                    draw.SimpleText("WARNING: CRITICAL", FONT_SMALL, xOffset + barWidth/2, yPos - 18, Color(255,0,0, 255 * math.abs(math.sin(CurTime()*8))), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
                
                -- ==============================================
                -- Barra de ESCUDO (Armor Monitor)
                -- ==============================================
                local armorY = sh - 50
                -- ¡Corrección! Usamos maxArm en lugar del '100' fijo.
                local armRatio = math.Clamp(arm/maxArm, 0, 1)
                local armColor = COLOR_ACCENT
                
                draw.SimpleText("SYS.DEF // SHIELD", FONT_SMALL, xOffset, armorY - 18, COLOR_TEXT_TITLE, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                draw.SimpleText(math.Round(arm) .. " / " .. maxArm, FONT_TITLE, xOffset + barWidth, armorY - 18, armRatio > 0 and armColor or COLOR_BORDER, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
                
                -- Fondo
                surface.SetDrawColor(0, 0, 0, 150)
                surface.DrawRect(xOffset, armorY, barWidth, 8)
                surface.SetDrawColor(COLOR_BORDER)
                surface.DrawOutlinedRect(xOffset - 1, armorY - 1, barWidth + 2, 10)
                
                if arm > 0 then
                    -- Relleno
                    surface.SetDrawColor(armColor.r, armColor.g, armColor.b, 200)
                    surface.DrawRect(xOffset, armorY, barWidth * armRatio, 8)
                    -- Neon
                    surface.SetDrawColor(armColor.r, armColor.g, armColor.b, 50)
                    for g = 1, 3 do
                        surface.DrawOutlinedRect(xOffset - g, armorY - g, (barWidth * armRatio) + (g*2), 8 + (g*2))
                    end
                end
                
                -- Segmentación (Ticks)
                surface.SetDrawColor(0, 0, 0, 200)
                for i = 1, 10 do
                    local tickX = xOffset + (barWidth / 10) * i
                    surface.DrawRect(tickX - 1, armorY, 2, 8)
                end
                
                surface.SetAlphaMultiplier(1)
            end

            local model = vgui.Create("ixModelPanel", center)
            model:SetModel(lp:GetModel())
            if IsValid(model.Entity) then
                model.Entity:SetSkin(lp:GetSkin())
                for _, v in ipairs(lp:GetBodyGroups() or {}) do
                    model.Entity:SetBodygroup(v.id, lp:GetBodygroup(v.id))
                end
            end
            model:SetFOV(45)
            model:SetCamPos(Vector(65, 0, 48))
            model:SetLookAt(Vector(0, 0, 38))
            function model:LayoutEntity(ent) ent:SetAngles(Angle(0, 45, 0)) end
            
            local oldOnRemove = model.OnRemove
            function model:OnRemove()
                if IsValid(self.Entity) then
                    self.Entity:Remove()
                end
                if isfunction(oldOnRemove) then
                    oldOnRemove(self)
                end
            end
            
            -- Evitar que el modelo cause stutters gestionándolo de forma determinista en el Think
            function model:Think()
                local bVisible = true
                if not IsValid(ix.gui.menu) or ix.gui.menu.bClosing or ix.gui.menu:GetAlpha() <= 5 then
                    bVisible = false
                end
                
                if bVisible then
                    local pnl = self
                    while IsValid(pnl) do
                        if pnl:GetAlpha() <= 5 or not pnl:IsVisible() then
                            bVisible = false
                            break
                        end
                        pnl = pnl:GetParent()
                    end
                end
                
                if not bVisible then
                    if IsValid(self.Entity) then
                        self.Entity:Remove()
                    end
                else
                    if not IsValid(self.Entity) then
                        self:SetModel(lp:GetModel())
                        if IsValid(self.Entity) then
                            self.Entity:SetSkin(lp:GetSkin())
                            for _, v in ipairs(lp:GetBodyGroups() or {}) do
                                self.Entity:SetBodygroup(v.id, lp:GetBodygroup(v.id))
                            end
                        end
                    end
                end
            end
            
            function center:OnSizeChanged(sw, sh)
                model:SetSize(sw, sh - 140)
                model:SetPos(0, 50)
            end

            -- --- COLUMNA DERECHA (Armadura + Inventario) ---
            local right = vgui.Create("DPanel", main)
            right:SetWide(rightW_clamped)
            right:Dock(RIGHT)
            right:DockMargin(15, 15, 15, 15)
            right.bNoBackgroundBlur = true
            right.Paint = function() end

            -- ARMADURA (Arriba)
            local armadura = CreateEquipSlot(right, 0, 0, rightW_clamped, 180, "Armadura", "equip_armor")
            armadura:Dock(TOP)
            armadura:DockMargin(0, 0, 0, 10)

            -- INVENTARIO (ixInventory nativo abajo)
            local gridBase = vgui.Create("DPanel", right)
            gridBase:Dock(FILL)
            gridBase.bNoBackgroundBlur = true
            gridBase.Paint = function(s, sw, sh)
                draw.SimpleText("INVENTARIO DE PERSONAJE", FONT_SMALL, 5, 0, COLOR_TEXT_TITLE)
                surface.SetDrawColor(COLOR_BORDER.r, COLOR_BORDER.g, COLOR_BORDER.b, 60)
                surface.DrawLine(5, 18, sw - 5, 18)
            end

            local needsHScroll = rightW > rightW_clamped

            scroll = gridBase:Add("DScrollPanel")
            scroll:Dock(FILL)
            scroll:DockMargin(0, 25, 0, needsHScroll and 15 or 0)
            
            -- Rediseño del VBar para estética táctica/holográfica
            local vbar = scroll:GetVBar()
            vbar:SetWide(6)
            vbar:SetHideButtons(true)
            function vbar:Paint(w, h)
                -- Pista (Fondo oscuro)
                surface.SetDrawColor(COLOR_BG.r, COLOR_BG.g, COLOR_BG.b, 200)
                surface.DrawRect(0, 0, w, h)
            end
            function vbar.btnGrip:Paint(w, h)
                -- Agarre (Línea de datos)
                local hover = self:IsHovered()
                surface.SetDrawColor(COLOR_ACCENT.r, COLOR_ACCENT.g, COLOR_ACCENT.b, hover and 255 or 150)
                surface.DrawRect(1, 0, w - 2, h)
            end

            -- Wrapper Horizontal (Contiene la cuadrícula sin comprimirla)
            local hWrap = scroll:Add("DPanel")
            hWrap:SetWide(rightW - 15)
            hWrap:SetPos(0, 0)
            hWrap.Paint = function() end

            canvas = hWrap:Add("DTileLayout")
            local canvasLayout = canvas.PerformLayout
            canvas.PerformLayout = nil -- optimization
            canvas:SetBorder(0)
            canvas:SetSpaceX(2)
            canvas:SetSpaceY(2)
            canvas:Dock(FILL)

            function canvas:OnChildAdded(child)
                if child.SetDraggable then
                    child:SetDraggable(false)
                    child:SetSizable(false)
                end
                self:InvalidateLayout()
            end

            ix.gui.menuInventoryContainer = canvas

            local panel = canvas:Add("ixInventory")
            panel:SetPos(0, 0)
            panel:SetDraggable(false)
            panel:SetSizable(false)
            panel:SetTitle(nil)
            panel.bNoBackgroundBlur = true
            panel.childPanels = {}

            local inventory = char:GetInventory()
            if (inventory) then
                panel:SetInventory(inventory)
                
                -- Pintado estético de celdas del inventario principal
                for _, row in pairs(panel.slots or {}) do
                    for _, slot in pairs(row) do
                        slot.Paint = function(s, sw, sh)
                            draw.RoundedBox(4, 2, 2, sw - 4, sh - 4, COLOR_SLOT_CELL)
                            surface.SetDrawColor(COLOR_SLOT_CELL_BORDER)
                            surface.DrawOutlinedRect(2, 2, sw - 4, sh - 4)
                        end
                    end
                end
            end

            ix.gui.inv1 = panel

            local function CustomCanvasLayout(self)
                local w = self:GetWide()
                local y = 0
                
                -- 1. Inventario principal del personaje
                if IsValid(ix.gui.inv1) then
                    local childW = ix.gui.inv1:GetWide()
                    local x = math.max(0, (w - childW) / 2)
                    ix.gui.inv1:SetPos(x, y)
                    y = y + ix.gui.inv1:GetTall() + 15
                end
                
                -- 2. Inventario de la Mochila/Maletín
                for _, child in ipairs(self:GetChildren()) do
                    if IsValid(child) and child ~= ix.gui.inv1 then
                        local childW = child:GetWide()
                        local x = math.max(0, (w - childW) / 2)
                        child:SetPos(x, y)
                        y = y + child:GetTall() + 15
                    end
                end
                
                self:SetTall(y)
                if IsValid(hWrap) then hWrap:SetTall(y) end
            end

            canvas.PerformLayout = CustomCanvasLayout
            canvas:Layout()

            -- Lógica de la barra HBar personalizada
            if needsHScroll then
                local hBar = gridBase:Add("DPanel")
                hBar:Dock(BOTTOM)
                hBar:SetTall(10)
                
                local maxScroll = rightW - rightW_clamped + 15
                local scrollPos = 0
                local isDragging = false
                local dragOffset = 0
                
                hBar.Paint = function(s, w, h)
                    surface.SetDrawColor(COLOR_BG.r, COLOR_BG.g, COLOR_BG.b, 200)
                    surface.DrawRect(0, 0, w, h)
                    
                    local gripW = math.max(40, w * (rightW_clamped / rightW))
                    local gripX = (scrollPos / maxScroll) * (w - gripW)
                    
                    local hover = s:IsHovered() or isDragging
                    surface.SetDrawColor(COLOR_ACCENT.r, COLOR_ACCENT.g, COLOR_ACCENT.b, hover and 255 or 150)
                    surface.DrawRect(gripX, 1, gripW, h - 2)
                end
                
                hBar.OnMousePressed = function(s, key)
                    if key == MOUSE_LEFT then
                        local w = s:GetWide()
                        local gripW = math.max(40, w * (rightW_clamped / rightW))
                        local gripX = (scrollPos / maxScroll) * (w - gripW)
                        local mx, _ = s:CursorPos()
                        
                        if mx >= gripX and mx <= gripX + gripW then
                            isDragging = true
                            dragOffset = mx - gripX
                            s:MouseCapture(true)
                        else
                            local newGripX = math.Clamp(mx - gripW/2, 0, w - gripW)
                            scrollPos = (newGripX / (w - gripW)) * maxScroll
                            hWrap:SetPos(-scrollPos, 0)
                        end
                    end
                end
                
                hBar.OnMouseReleased = function(s, key)
                    isDragging = false
                    s:MouseCapture(false)
                end
                
                hBar.Think = function(s)
                    if isDragging then
                        if not input.IsMouseDown(MOUSE_LEFT) then
                            isDragging = false
                            s:MouseCapture(false)
                            return
                        end
                        
                        local mx, _ = s:CursorPos()
                        local w = s:GetWide()
                        local gripW = math.max(40, w * (rightW_clamped / rightW))
                        local newGripX = math.Clamp(mx - dragOffset, 0, w - gripW)
                        
                        scrollPos = (newGripX / (w - gripW)) * maxScroll
                        hWrap:SetPos(-scrollPos, 0)
                    end
                end
            end

            main.bInitialized = true
        end
    }
end)

-- ============================================================
-- Rediseño del Menú Principal de Helix (Botones Laterales)
-- ============================================================
-- Estructura real de Helix (cl_menu.lua):
--   self.tabs (DScrollPanel) -> ixMenuSelectionButton apilados con Dock(TOP)  [pestañas]
--   self.buttons             -> ixMenuButton con Dock(BOTTOM)                 [PERSONAJES / VOLVER]
-- El solape se produce porque SizeToContents() deja alturas inconsistentes.
-- Fijamos una altura uniforme vía PerformLayout para un apilado limpio.

local SWRP_BTN_HEIGHT = 42  -- Altura uniforme de cada botón. Ajusta a tu boceto.

local function SWRP_PaintMenuButton(self, w, h)
    local hover  = self:IsHovered()
    local active = self.GetSelected and self:GetSelected() or false

    -- Fondo base táctico
    surface.SetDrawColor(SWRP_CFG.ColorBG.r, SWRP_CFG.ColorBG.g, SWRP_CFG.ColorBG.b, hover and SWRP_CFG.HoverAlphaBg or 150)
    surface.DrawRect(0, 0, w, h)

    -- Scanlines
    surface.SetDrawColor(0, 0, 0, 80)
    for i = 0, h, 4 do surface.DrawLine(0, i, w, i) end

    -- Selección / hover (holográfico)
    if hover or active then
        surface.SetDrawColor(SWRP_CFG.ColorAccent.r, SWRP_CFG.ColorAccent.g, SWRP_CFG.ColorAccent.b, active and 120 or 40)
        surface.DrawRect(0, 0, w, h)

        surface.SetDrawColor(SWRP_CFG.ColorAccent)
        surface.DrawRect(0, 0, 4, h)               -- borde luminoso izquierdo
        surface.DrawRect(w - 6, h/2 - 4, 2, 8)     -- acento derecho
    else
        surface.SetDrawColor(SWRP_CFG.ColorBorder)
        surface.DrawRect(0, 0, 2, h)               -- borde inactivo
    end

    -- Texto
    local textColor = active and SWRP_CFG.ColorWhite or (hover and SWRP_CFG.ColorAccent or Color(150, 180, 200, 255))
    local font = self.font or "ixMenuButtonFont"
    local btnText = ((self.name and L(self.name)) or self:GetText() or ""):upper()

    draw.SimpleText(btnText, font, 18, h/2 + 2, Color(0, 0, 0, 200), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    draw.SimpleText(btnText, font, 16, h/2,     textColor,           TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

    return true -- evita el pintado nativo de Helix
end

-- ============================================================
-- Aplica el estilo SWRP únicamente a los botones del menú F1
-- (ixMenu). NO tocamos las clases globalmente para no romper el
-- resto del UI de Helix: selección/creación de personaje,
-- listados, etc. mantienen su apariencia original.
--
-- El truco: hacemos detour de ixMenu:PopulateTabs y, después de
-- que Helix cree sus botones, sobrescribimos Paint/Altura SOLO
-- en esas instancias.
-- ============================================================

local function SWRP_NormalizeMenuButtons(menuPanel)
    if not IsValid(menuPanel) then return end

    -- Pestañas (CONFIGURACIÓN, AYUDA, INVENTARIO, MARCADOR, TÚ, OPCIONES…)
    if menuPanel.tabs and menuPanel.tabs.buttons then
        for _, btn in ipairs(menuPanel.tabs.buttons) do
            if IsValid(btn) then
                btn.Paint = SWRP_PaintMenuButton
                if btn.SetTall then btn:SetTall(SWRP_BTN_HEIGHT) end
            end
        end
    end

    -- Botones inferiores del propio menú (PERSONAJES / VOLVER)
    if IsValid(menuPanel.buttons) then
        for _, child in ipairs(menuPanel.buttons:GetChildren()) do
            if IsValid(child) and child.SetText and child ~= menuPanel.tabs then
                child.Paint = SWRP_PaintMenuButton
                if child.SetTall then child:SetTall(SWRP_BTN_HEIGHT) end
            end
        end
    end
end

local function SWRP_DetourMenu()
    local tbl = vgui.GetControlTable("ixMenu")
    if not tbl then return false end
    if tbl.SWRP_DetourApplied then return true end

    local originalPopulate = tbl.PopulateTabs
    function tbl:PopulateTabs(...)
        local ret = originalPopulate and originalPopulate(self, ...)
        SWRP_NormalizeMenuButtons(self)
        return ret
    end

    -- Doble seguro: también re-aplicamos en cada layout, por si
    -- algún hook tardío vuelve a tocar button.Paint.
    local originalLayout = tbl.PerformLayout
    function tbl:PerformLayout(...)
        if originalLayout then originalLayout(self, ...) end
        SWRP_NormalizeMenuButtons(self)
    end

    tbl.SWRP_DetourApplied = true
    return true
end

timer.Simple(0, function()
    if not SWRP_DetourMenu() then
        -- Si ixMenu aún no está registrado, reintenta más tarde.
        timer.Simple(0.5, SWRP_DetourMenu)
    end
end)