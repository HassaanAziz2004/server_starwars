-- ============================================================
-- Archivo: cl_inventory.lua
-- Plugin: SWRP Inventory
-- Tema: Imperio Galáctico
-- ============================================================

if SERVER then return end

print("[SWRP INVENTORY] Cargando cl_inventory.lua...")

local PLUGIN = PLUGIN

-- ============================================================
-- Configuración Global del Diseño
-- ============================================================
SWRP_CFG = {
    -- PALETA IMPERIAL
    ColorBG          = Color(4, 4, 6, 200),
    ColorSlot        = Color(10, 10, 14, 220),
    ColorBorder      = Color(70, 70, 78, 120),
    ColorBorderHover = Color(200, 20, 20, 255),
    ColorAccent      = Color(180, 18, 18, 200),
    ColorWhite       = Color(215, 215, 220, 255),
    ColorTextTitle   = Color(210, 210, 215, 255),
    ColorCell        = Color(8, 6, 6, 140),
    ColorCellBorder  = Color(100, 15, 15, 50),

    BlurIntensity    = 8,
    ScanlineAlpha    = 40,
    HoverAlphaBg     = 220,
    ColWidthPct      = 0.16,
    MaxRightColPct   = 0.35,
    MinColWidth      = 280,
}

local COLOR_BG           = SWRP_CFG.ColorBG
local COLOR_SLOT         = SWRP_CFG.ColorSlot
local COLOR_BORDER       = SWRP_CFG.ColorBorder
local COLOR_BORDER_HOVER = SWRP_CFG.ColorBorderHover
local COLOR_ACCENT       = SWRP_CFG.ColorAccent
local COLOR_WHITE        = SWRP_CFG.ColorWhite
local COLOR_TEXT_TITLE   = SWRP_CFG.ColorTextTitle
local COLOR_SLOT_CELL    = SWRP_CFG.ColorCell
local COLOR_SLOT_CELL_BORDER = SWRP_CFG.ColorCellBorder

surface.CreateFont("swrp_tech_title", { font = "Trebuchet MS", size = 14, weight = 800, antialias = true, shadow = true })
surface.CreateFont("swrp_tech_small", { font = "Trebuchet MS", size = 12, weight = 400, antialias = true })
surface.CreateFont("swrp_tech_large", { font = "Trebuchet MS", size = 24, weight = 800, antialias = true, shadow = true })

local FONT_SMALL = "swrp_tech_small"
local FONT_NAME  = "swrp_tech_large"
local FONT_TITLE = "swrp_tech_title"

local function SafeGetIcon(obj)
    if not obj then return nil end
    if type(obj.GetIcon) == "function" then return obj:GetIcon() end
    return obj.icon or obj.IconOverride
end

-- Slot básico
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

-- Celdas de inventario estilo Imperial
local IX_INVENTORY = vgui.GetControlTable("ixInventory")
if IX_INVENTORY then
    local oldBuildSlots = IX_INVENTORY.BuildSlots
    function IX_INVENTORY:BuildSlots()
        if oldBuildSlots then oldBuildSlots(self) end
        for _, row in pairs(self.slots or {}) do
            for _, slot in pairs(row) do
                slot.Paint = function(s, sw, sh)
                    local inv = ix.item.inventories[self.invID]
                    local isEquip = inv and inv.vars and inv.vars.isBag and string.sub(inv.vars.isBag, 1, 5) == "equip"
                    if isEquip then return end
                    draw.RoundedBox(0, 2, 2, sw - 4, sh - 4, COLOR_SLOT_CELL)
                    surface.SetDrawColor(COLOR_SLOT_CELL_BORDER)
                    surface.DrawOutlinedRect(2, 2, sw - 4, sh - 4)
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

-- Slot de equipamiento
local function CreateEquipSlot(parent, x, y, w, h, label, invType)
    local char  = LocalPlayer():GetCharacter()
    local invID = char:GetData(invType)

    local wrap = vgui.Create("DPanel", parent)
    wrap:SetSize(w, h)
    wrap.Paint = function() end

    local p = vgui.Create("DPanel", wrap)
    p:SetSize(w, h)
    p:CenterHorizontal()
    p.bNoBackgroundBlur = true

    function p:Paint(sw, sh)
        local hover   = self:IsHovered()
        local hasItem = false
        if invID then
            local inv = ix.item.inventories[invID]
            if inv and table.Count(inv:GetItems()) > 0 then hasItem = true end
        end

        surface.SetDrawColor(COLOR_SLOT)
        surface.DrawRect(0, 0, sw, sh)
        surface.SetDrawColor(0, 0, 0, 50)
        for i = 0, sh, 4 do surface.DrawLine(0, i, sw, i) end
        surface.SetDrawColor(0, 0, 0, 220)
        surface.DrawRect(0, 0, sw, 22)
        draw.SimpleText(label:upper(), FONT_TITLE, sw / 2, 11, COLOR_TEXT_TITLE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        local sysName = string.Replace(invType:upper(), "EQUIP_", "")
        draw.SimpleText("IMP."..sysName, FONT_SMALL, 4, sh - 14, Color(180, 18, 18, 25), TEXT_ALIGN_LEFT)
        draw.SimpleText("OP.RDY", FONT_SMALL, sw - 4, 4, Color(180, 18, 18, 25), TEXT_ALIGN_RIGHT)

        local lc = hasItem and COLOR_ACCENT or COLOR_BORDER
        surface.SetDrawColor(lc.r, lc.g, lc.b, hasItem and 255 or 100)
        surface.DrawLine(0, 22, sw, 22)
        if hasItem then
            surface.SetDrawColor(lc.r, lc.g, lc.b, 50)
            surface.DrawLine(0, 23, sw, 23)
        end

        local cc = hasItem and COLOR_ACCENT or COLOR_BORDER
        if hover then cc = COLOR_BORDER_HOVER end
        surface.SetDrawColor(cc)
        local cl, th = 15, 2
        surface.DrawRect(0, 0, cl, th)    surface.DrawRect(0, 0, th, cl)
        surface.DrawRect(sw-cl, 0, cl, th) surface.DrawRect(sw-th, 0, th, cl)
        surface.DrawRect(0, sh-th, cl, th) surface.DrawRect(0, sh-cl, th, cl)
        surface.DrawRect(sw-cl, sh-th, cl, th) surface.DrawRect(sw-th, sh-cl, th, cl)

        if hover then
            surface.SetDrawColor(COLOR_BORDER_HOVER.r, COLOR_BORDER_HOVER.g, COLOR_BORDER_HOVER.b, 50)
            surface.DrawOutlinedRect(0, 0, sw, sh)
            surface.SetDrawColor(COLOR_BORDER_HOVER.r, COLOR_BORDER_HOVER.g, COLOR_BORDER_HOVER.b, 20)
            surface.DrawRect(0, 0, sw, sh)
        else
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

            for _, row in pairs(invPanel.slots or {}) do
                for _, slot in pairs(row) do
                    slot.Paint = function() end
                end
            end

            p.Think = function(self)
                if not IsValid(invPanel) or not IsValid(wrap) then return end
                local hasItem, iconW, iconH, iconPanel = false, 0, 0, nil
                for _, child in ipairs(invPanel:GetChildren()) do
                    if child.GetItemID or child.itemTable or (child:GetClassName() == "ixItemIcon") then
                        hasItem   = true
                        iconPanel = child
                        local cw, ch = child:GetSize()
                        if cw > 0 and ch > 0 then iconW = cw; iconH = ch end
                        break
                    end
                end
                local targetW = math.max(w, iconW)
                local targetH = math.max(h, iconH + 22)
                if self:GetWide() ~= targetW or self:GetTall() ~= targetH then
                    self:SetSize(targetW, targetH)
                    self:CenterHorizontal()
                    wrap:SetSize(targetW, targetH)
                    local par = wrap:GetParent()
                    if IsValid(par) then par:InvalidateLayout() end
                end
                if hasItem and iconW > 0 and IsValid(iconPanel) then
                    local ix2, iy = iconPanel:GetPos()
                    invPanel:SetSize(ix2 + iconW, iy + iconH)
                    local CX = targetW / 2
                    local CY = 22 + (targetH - 22) / 2
                    local IX = ix2 + (iconW / 2)
                    local IY = iy  + (iconH / 2)
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

-- ============================================================
-- Integración en el menú TAB
-- ============================================================
hook.Add("CreateMenuButtons", "ixInventory", function(tabs)
    tabs["inv"] = {
        bDefault = true,
        OnCanRun = function() return IsValid(LocalPlayer():GetCharacter()) end,
        Create = function(info, container)
            local lp   = LocalPlayer()
            local char = lp:GetCharacter()
            local scroll, canvas

            local main = vgui.Create("DPanel", container)
            main:Dock(FILL)
            main:DockMargin(40, 40, 40, 40)
            main.bNoBackgroundBlur = true

            -- FONDO IMPERIAL
            main.Paint = function(s, sw, sh)
                ix.util.DrawBlur(s, 8)
                draw.RoundedBox(0, 0, 0, sw, sh, COLOR_BG)
                surface.SetDrawColor(55, 55, 60, 8)
                for i = 0, sw, 48 do surface.DrawLine(i, 0, i, sh) end
                for i = 0, sh, 48 do surface.DrawLine(0, i, sw, i) end
                -- Banda roja superior
                surface.SetDrawColor(180, 18, 18, 200)
                surface.DrawRect(0, 0, sw, 3)
                surface.SetDrawColor(220, 30, 30, 60)
                surface.DrawRect(0, 3, sw, 1)
                -- Banda roja inferior
                surface.SetDrawColor(180, 18, 18, 200)
                surface.DrawRect(0, sh - 3, sw, 3)
                -- Borde gris acero
                surface.SetDrawColor(70, 70, 78, 180)
                surface.DrawOutlinedRect(0, 0, sw, sh)
                surface.SetDrawColor(50, 50, 56, 100)
                surface.DrawOutlinedRect(1, 1, sw - 2, sh - 2)
                -- Esquinas rojas imperiales
                surface.SetDrawColor(180, 18, 18, 200)
                local cl, th = 40, 3
                surface.DrawRect(0, 0, cl, th)    surface.DrawRect(0, 0, th, cl)
                surface.DrawRect(sw-cl, 0, cl, th) surface.DrawRect(sw-th, 0, th, cl)
                surface.DrawRect(0, sh-th, cl, th) surface.DrawRect(0, sh-cl, th, cl)
                surface.DrawRect(sw-cl, sh-th, cl, th) surface.DrawRect(sw-th, sh-cl, th, cl)
                -- Textos clasificados
                draw.SimpleText("IMPERIAL PERSONNEL REGISTRY // CLASSIFIED", FONT_SMALL, sw/2, sh - 8, Color(180,18,18,30), TEXT_ALIGN_CENTER)
                draw.SimpleText("GALACTIC EMPIRE — AUTHORIZED ACCESS ONLY",  FONT_SMALL, sw/2,      8, Color(180,18,18,30), TEXT_ALIGN_CENTER)
            end

            local lastBagID = nil
            main.Think = function(self)
                if not self.bInitialized then return end
                local b_invID = char:GetData("equip_bag")
                local currentBag, currentBagItem = nil, nil
                if b_invID then
                    local b_inv = ix.item.inventories[b_invID]
                    if b_inv then
                        for _, v in pairs(b_inv:GetItems()) do
                            if v.isBag or v.base == "base_bags" then
                                local bagInvID = v:GetData("id")
                                if bagInvID and ix.item.inventories[bagInvID] then
                                    currentBag     = bagInvID
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
                                if IsValid(canvas) then canvas:InvalidateLayout(true) canvas:Layout() end
                                if IsValid(scroll)  then scroll:InvalidateLayout(true) end
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
                        timer.Simple(0.2, function()
                            if not IsValid(self) or not currentBagItem then return end
                            if IsValid(ix.gui["inv" .. currentBag]) then return end
                            if currentBagItem.functions and currentBagItem.functions.View then
                                currentBagItem.functions.View.OnClick(currentBagItem)
                                timer.Simple(0.1, function()
                                    if IsValid(canvas) then canvas:InvalidateLayout(true) canvas:Layout() end
                                    if IsValid(scroll)  then scroll:InvalidateLayout(true) end
                                    if IsValid(self) and not IsValid(ix.gui["inv"..currentBag]) then
                                        self.bCreatingBag = false
                                    end
                                end)
                            end
                        end)
                    end
                end
            end

            main.OnRemove = function(self)
                if lastBagID then
                    local pnl = ix.gui["inv" .. lastBagID]
                    if IsValid(pnl) then pnl:Remove() end
                    ix.gui["inv" .. lastBagID] = nil
                end
            end

            local sw2      = ScrW()
            local colW     = math.max(SWRP_CFG.MinColWidth, sw2 * SWRP_CFG.ColWidthPct)
            local maxRightW = sw2 * SWRP_CFG.MaxRightColPct
            local rightW   = colW + 40
            local inventory = char:GetInventory()
            if inventory then
                local invW = inventory:GetSize()
                rightW = math.max(rightW, (invW * 64) + 32)
            end
            local rightW_clamped = math.min(rightW, maxRightW)

            -- COLUMNA IZQUIERDA
            local left = vgui.Create("DPanel", main)
            left:SetWide(colW)
            left:Dock(LEFT)
            left:DockMargin(15, 15, 15, 15)
            left.bNoBackgroundBlur = true
            left.Paint = function() end

            local arma1 = CreateEquipSlot(left, 0, 0, colW, 160, "Arma Primaria",   "equip_wep1")
            arma1:Dock(TOP) arma1:DockMargin(0,0,0,10)
            local arma2 = CreateEquipSlot(left, 0, 0, colW, 160, "Arma Secundaria", "equip_wep2")
            arma2:Dock(TOP) arma2:DockMargin(0,0,0,10)

            local bottomRow = vgui.Create("DPanel", left)
            bottomRow:Dock(TOP) bottomRow:SetTall(160)
            bottomRow.Paint = function() end
            local smallW = colW / 2 - 5
            local pistola = CreateEquipSlot(bottomRow, 0, 0, smallW, 160, "Pistola",  "equip_pistol")
            pistola:Dock(LEFT)
            local mochila = CreateEquipSlot(bottomRow, 0, 0, smallW, 160, "Mochila",  "equip_bag")
            mochila:Dock(RIGHT)

            -- COLUMNA CENTRAL
            local center = vgui.Create("DPanel", main)
            center:Dock(FILL)
            center:DockMargin(0, 15, 0, 15)
            center.bNoBackgroundBlur = true

            center.Paint = function(s, sw, sh)
                local alpha = IsValid(ix.gui.menu) and (ix.gui.menu:GetAlpha() / 255) or 1
                surface.SetAlphaMultiplier(alpha)
                draw.SimpleText(char:GetName():upper(), FONT_NAME, sw/2+1, 13, Color(0,0,0,180), TEXT_ALIGN_CENTER)
                draw.SimpleText(char:GetName():upper(), FONT_NAME, sw/2,   12, COLOR_WHITE,       TEXT_ALIGN_CENTER)
                local f = ix.faction.Get(char:GetFaction())
                if f then
                    draw.SimpleText(f.name:upper(), FONT_SMALL, sw/2+1, 39, Color(0,0,0,180),  TEXT_ALIGN_CENTER)
                    draw.SimpleText(f.name:upper(), FONT_SMALL, sw/2,   38, COLOR_ACCENT,       TEXT_ALIGN_CENTER)
                end
                surface.SetAlphaMultiplier(1)
            end

            center.PaintOver = function(s, sw, sh)
                local alpha = IsValid(ix.gui.menu) and (ix.gui.menu:GetAlpha() / 255) or 1
                surface.SetAlphaMultiplier(alpha)

                local hp    = lp:Health()
                local maxHp = lp:GetNetVar("maxHealth", lp:GetMaxHealth())
                if maxHp < 1 then maxHp = 100 end
                local arm    = lp:Armor()
                local maxArm = lp:GetNetVar("maxArmor", lp.GetMaxArmor and lp:GetMaxArmor() or 100)
                if maxArm < 1 then maxArm = 100 end
                if maxHp  < hp  then maxHp  = hp  end
                if maxArm < arm then maxArm = arm end

                local barWidth = sw - 120
                local xOffset  = 60

                -- Barra de VIDA
                local yPos   = sh - 90
                local hpRatio = math.Clamp(hp/maxHp, 0, 1)
                local hpColor = hpRatio < 0.3 and Color(255, 50, 50) or Color(100, 255, 150)

                draw.SimpleText("IMP.BIO // VITALS", FONT_SMALL, xOffset, yPos-18, COLOR_TEXT_TITLE, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                draw.SimpleText(math.Round(hp).." / "..maxHp, FONT_TITLE, xOffset+barWidth, yPos-18, hpColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

                surface.SetDrawColor(0,0,0,150)
                surface.DrawRect(xOffset, yPos, barWidth, 8)
                surface.SetDrawColor(COLOR_BORDER)
                surface.DrawOutlinedRect(xOffset-1, yPos-1, barWidth+2, 10)
                surface.SetDrawColor(hpColor.r, hpColor.g, hpColor.b, 200)
                surface.DrawRect(xOffset, yPos, barWidth * hpRatio, 8)
                surface.SetDrawColor(hpColor.r, hpColor.g, hpColor.b, 50)
                for g = 1, 3 do
                    surface.DrawOutlinedRect(xOffset-g, yPos-g, (barWidth*hpRatio)+(g*2), 8+(g*2))
                end
                surface.SetDrawColor(0,0,0,200)
                for i = 1, 10 do
                    local tickX = xOffset + (barWidth/10)*i
                    surface.DrawRect(tickX-1, yPos, 2, 8)
                end
                if hpRatio < 0.3 then
                    surface.SetDrawColor(255,0,0, math.abs(math.sin(CurTime()*8))*100)
                    surface.DrawRect(xOffset, yPos, barWidth, 8)
                    draw.SimpleText("WARNING: CRITICAL", FONT_SMALL, xOffset+barWidth/2, yPos-18, Color(255,0,0, 255*math.abs(math.sin(CurTime()*8))), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end

                -- Barra de ARMADURA
                local armorY  = sh - 50
                local armRatio = math.Clamp(arm/maxArm, 0, 1)
                local armColor = COLOR_ACCENT

                draw.SimpleText("IMP.DEF // ARMOR", FONT_SMALL, xOffset, armorY-18, COLOR_TEXT_TITLE, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                draw.SimpleText(math.Round(arm).." / "..maxArm, FONT_TITLE, xOffset+barWidth, armorY-18, armRatio > 0 and armColor or COLOR_BORDER, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

                surface.SetDrawColor(0,0,0,150)
                surface.DrawRect(xOffset, armorY, barWidth, 8)
                surface.SetDrawColor(COLOR_BORDER)
                surface.DrawOutlinedRect(xOffset-1, armorY-1, barWidth+2, 10)
                if arm > 0 then
                    surface.SetDrawColor(armColor.r, armColor.g, armColor.b, 200)
                    surface.DrawRect(xOffset, armorY, barWidth*armRatio, 8)
                    surface.SetDrawColor(armColor.r, armColor.g, armColor.b, 50)
                    for g = 1, 3 do
                        surface.DrawOutlinedRect(xOffset-g, armorY-g, (barWidth*armRatio)+(g*2), 8+(g*2))
                    end
                end
                surface.SetDrawColor(0,0,0,200)
                for i = 1, 10 do
                    local tickX = xOffset + (barWidth/10)*i
                    surface.DrawRect(tickX-1, armorY, 2, 8)
                end
                surface.SetAlphaMultiplier(1)
            end

            -- ============================================================
            -- MODELO 3D — DModelPanel con animación idle y drag para rotar
            -- ============================================================
            local modelAnimApplied = false
            local modelAngle       = 30
            local invIsDragging    = false
            local invLastMouseX    = 0

            local model = vgui.Create("DModelPanel", center)
            model:SetModel(lp:GetModel())
            if IsValid(model.Entity) then
                model.Entity:SetSkin(lp:GetSkin())
                for _, v in ipairs(lp:GetBodyGroups() or {}) do
                    model.Entity:SetBodygroup(v.id, lp:GetBodygroup(v.id))
                end
            end
            model:SetFOV(40)
            model:SetCamPos(Vector(80, 0, 58))
            model:SetLookAt(Vector(0, 0, 58))
            model:SetMouseInputEnabled(true)

            model.OnMousePressed = function(self, code)
                if code == MOUSE_LEFT then
                    invIsDragging = true
                    invLastMouseX = gui.MouseX()
                end
            end
            model.OnMouseReleased = function(self, code)
                if code == MOUSE_LEFT then invIsDragging = false end
            end

            function model:LayoutEntity(ent)
                ent:SetSkin(lp:GetSkin())
                if not modelAnimApplied then
                    local seqNames = {"idle_unarmed","idle","walk_all","walk","stand_all","stand","idle_angry"}
                    local seq = -1
                    for _, name in ipairs(seqNames) do
                        local s = ent:LookupSequence(name)
                        if s and s >= 0 then seq = s break end
                    end
                    if seq < 0 then seq = 0 end
                    ent:ResetSequence(seq)
                    ent:SetPlaybackRate(1)
                    modelAnimApplied = true
                end
                if invIsDragging then
                    local dx = gui.MouseX() - invLastMouseX
                    modelAngle    = modelAngle + dx * 0.6
                    invLastMouseX = gui.MouseX()
                end
                ent:SetAngles(Angle(0, modelAngle, 0))
            end

            local oldOnRemove = model.OnRemove
            function model:OnRemove()
                if IsValid(self.Entity) then self.Entity:Remove() end
                if isfunction(oldOnRemove) then oldOnRemove(self) end
            end

            -- Ocultar/mostrar entidad cuando el inventario no está visible
            -- (fix para que el modelo no quede flotando en el mundo)
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
                    if IsValid(self.Entity) then self.Entity:Remove() end
                else
                    if not IsValid(self.Entity) then
                        self:SetModel(lp:GetModel())
                        if IsValid(self.Entity) then
                            self.Entity:SetSkin(lp:GetSkin())
                            for _, v in ipairs(lp:GetBodyGroups() or {}) do
                                self.Entity:SetBodygroup(v.id, lp:GetBodygroup(v.id))
                            end
                            modelAnimApplied = false  -- reaplicar animación al recrear entidad
                        end
                    end
                end
            end

            function center:OnSizeChanged(sw, sh)
                model:SetSize(sw, sh - 140)
                model:SetPos(0, 50)
            end

            -- COLUMNA DERECHA
            local right = vgui.Create("DPanel", main)
            right:SetWide(rightW_clamped)
            right:Dock(RIGHT)
            right:DockMargin(15, 15, 15, 15)
            right.bNoBackgroundBlur = true
            right.Paint = function() end

            local armadura = CreateEquipSlot(right, 0, 0, rightW_clamped, 180, "Armadura", "equip_armor")
            armadura:Dock(TOP) armadura:DockMargin(0,0,0,10)

            local gridBase = vgui.Create("DPanel", right)
            gridBase:Dock(FILL)
            gridBase.bNoBackgroundBlur = true
            gridBase.Paint = function(s, sw, sh)
                draw.SimpleText("INVENTARIO DE PERSONAJE", FONT_SMALL, 5, 0, COLOR_TEXT_TITLE)
                surface.SetDrawColor(COLOR_BORDER.r, COLOR_BORDER.g, COLOR_BORDER.b, 60)
                surface.DrawLine(5, 18, sw-5, 18)
            end

            local needsHScroll = rightW > rightW_clamped
            scroll = gridBase:Add("DScrollPanel")
            scroll:Dock(FILL)
            scroll:DockMargin(0, 25, 0, needsHScroll and 15 or 0)

            local vbar = scroll:GetVBar()
            vbar:SetWide(6)
            vbar:SetHideButtons(true)
            function vbar:Paint(w, h)
                surface.SetDrawColor(COLOR_BG.r, COLOR_BG.g, COLOR_BG.b, 200)
                surface.DrawRect(0, 0, w, h)
            end
            function vbar.btnGrip:Paint(w, h)
                local hover = self:IsHovered()
                surface.SetDrawColor(COLOR_ACCENT.r, COLOR_ACCENT.g, COLOR_ACCENT.b, hover and 255 or 150)
                surface.DrawRect(1, 0, w-2, h)
            end

            local hWrap = scroll:Add("DPanel")
            hWrap:SetWide(rightW - 15)
            hWrap:SetPos(0, 0)
            hWrap.Paint = function() end

            canvas = hWrap:Add("DTileLayout")
            canvas.PerformLayout = nil
            canvas:SetBorder(0) canvas:SetSpaceX(2) canvas:SetSpaceY(2)
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
            panel:SetPos(0,0)
            panel:SetDraggable(false) panel:SetSizable(false) panel:SetTitle(nil)
            panel.bNoBackgroundBlur = true
            panel.childPanels = {}

            local inventory2 = char:GetInventory()
            if inventory2 then
                panel:SetInventory(inventory2)
                for _, row in pairs(panel.slots or {}) do
                    for _, slot in pairs(row) do
                        slot.Paint = function(s, sw, sh)
                            draw.RoundedBox(4, 2, 2, sw-4, sh-4, COLOR_SLOT_CELL)
                            surface.SetDrawColor(COLOR_SLOT_CELL_BORDER)
                            surface.DrawOutlinedRect(2, 2, sw-4, sh-4)
                        end
                    end
                end
            end

            ix.gui.inv1 = panel

            local function CustomCanvasLayout(self)
                local w = self:GetWide()
                local y = 0
                if IsValid(ix.gui.inv1) then
                    local childW = ix.gui.inv1:GetWide()
                    local x = math.max(0, (w - childW) / 2)
                    ix.gui.inv1:SetPos(x, y)
                    y = y + ix.gui.inv1:GetTall() + 15
                end
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

            if needsHScroll then
                local hBar = gridBase:Add("DPanel")
                hBar:Dock(BOTTOM) hBar:SetTall(10)
                local maxScroll = rightW - rightW_clamped + 15
                local scrollPos, isDragging2, dragOffset = 0, false, 0
                hBar.Paint = function(s, w, h)
                    surface.SetDrawColor(COLOR_BG.r, COLOR_BG.g, COLOR_BG.b, 200)
                    surface.DrawRect(0, 0, w, h)
                    local gripW = math.max(40, w*(rightW_clamped/rightW))
                    local gripX = (scrollPos/maxScroll)*(w-gripW)
                    local hover = s:IsHovered() or isDragging2
                    surface.SetDrawColor(COLOR_ACCENT.r, COLOR_ACCENT.g, COLOR_ACCENT.b, hover and 255 or 150)
                    surface.DrawRect(gripX, 1, gripW, h-2)
                end
                hBar.OnMousePressed = function(s, key)
                    if key == MOUSE_LEFT then
                        local w = s:GetWide()
                        local gripW = math.max(40, w*(rightW_clamped/rightW))
                        local gripX = (scrollPos/maxScroll)*(w-gripW)
                        local mx, _ = s:CursorPos()
                        if mx >= gripX and mx <= gripX+gripW then
                            isDragging2 = true; dragOffset = mx-gripX; s:MouseCapture(true)
                        else
                            local newGripX = math.Clamp(mx-gripW/2, 0, w-gripW)
                            scrollPos = (newGripX/(w-gripW))*maxScroll
                            hWrap:SetPos(-scrollPos, 0)
                        end
                    end
                end
                hBar.OnMouseReleased = function(s) isDragging2 = false s:MouseCapture(false) end
                hBar.Think = function(s)
                    if isDragging2 then
                        if not input.IsMouseDown(MOUSE_LEFT) then isDragging2=false s:MouseCapture(false) return end
                        local mx, _ = s:CursorPos()
                        local w = s:GetWide()
                        local gripW = math.max(40, w*(rightW_clamped/rightW))
                        local newGripX = math.Clamp(mx-dragOffset, 0, w-gripW)
                        scrollPos = (newGripX/(w-gripW))*maxScroll
                        hWrap:SetPos(-scrollPos, 0)
                    end
                end
            end

            main.bInitialized = true
        end
    }
end)

-- ============================================================
-- Rediseño botones del menú lateral (F1)
-- ============================================================
local SWRP_BTN_HEIGHT = 42

local function SWRP_PaintMenuButton(self, w, h)
    local hover  = self:IsHovered()
    local active = self.GetSelected and self:GetSelected() or false

    surface.SetDrawColor(SWRP_CFG.ColorBG.r, SWRP_CFG.ColorBG.g, SWRP_CFG.ColorBG.b, hover and SWRP_CFG.HoverAlphaBg or 150)
    surface.DrawRect(0, 0, w, h)
    surface.SetDrawColor(0, 0, 0, 80)
    for i = 0, h, 4 do surface.DrawLine(0, i, w, i) end

    if hover or active then
        surface.SetDrawColor(SWRP_CFG.ColorAccent.r, SWRP_CFG.ColorAccent.g, SWRP_CFG.ColorAccent.b, active and 120 or 40)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(SWRP_CFG.ColorAccent)
        surface.DrawRect(0, 0, 4, h)
        surface.DrawRect(w-6, h/2-4, 2, 8)
    else
        surface.SetDrawColor(SWRP_CFG.ColorBorder)
        surface.DrawRect(0, 0, 2, h)
    end

    local textColor = active and SWRP_CFG.ColorWhite or (hover and SWRP_CFG.ColorAccent or Color(150, 180, 200, 255))
    local font = self.font or "ixMenuButtonFont"
    local btnText = ((self.name and L(self.name)) or self:GetText() or ""):upper()
    draw.SimpleText(btnText, font, 18, h/2+2, Color(0,0,0,200), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    draw.SimpleText(btnText, font, 16, h/2,   textColor,         TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    return true
end

local function SWRP_NormalizeMenuButtons(menuPanel)
    if not IsValid(menuPanel) then return end
    if menuPanel.tabs and menuPanel.tabs.buttons then
        for _, btn in ipairs(menuPanel.tabs.buttons) do
            if IsValid(btn) then
                btn.Paint = SWRP_PaintMenuButton
                if btn.SetTall then btn:SetTall(SWRP_BTN_HEIGHT) end
            end
        end
    end
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
        timer.Simple(0.5, SWRP_DetourMenu)
    end
end)