local PLUGIN = PLUGIN

-- Variables de color basadas en tu imagen de referencia
local color_bg = Color(20, 25, 30, 240)
local color_accent = Color(0, 170, 255)
local color_accent_dark = Color(0, 100, 150, 100)
local color_panel_bg = Color(10, 15, 20, 200)

-- =========================================================================
-- FUNCIONES AUXILIARES DE RENDERIZADO
-- =========================================================================
local function DrawTechCorners(x, y, w, h, length, color)
    surface.SetDrawColor(color)
    surface.DrawLine(x, y, x + length, y)
    surface.DrawLine(x, y, x, y + length)
    surface.DrawLine(x + w - length, y, x + w, y)
    surface.DrawLine(x + w, y, x + w, y + length)
    surface.DrawLine(x, y + h, x + length, y + h)
    surface.DrawLine(x, y + h - length, x, y + h)
    surface.DrawLine(x + w - length, y + h, x + w, y + h)
    surface.DrawLine(x + w, y + h - length, x + w, y + h)
end

-- =========================================================================
-- RECEPCIÓN DE RED
-- =========================================================================
netstream.Hook("ixSkillOpenUI", function()
    if (IsValid(ix.gui.skillTree)) then
        ix.gui.skillTree:Remove()
    end
    ix.gui.skillTree = vgui.Create("ixSkillTreePanel")
end)

-- =========================================================================
-- PANEL PRINCIPAL VGUI
-- =========================================================================
local PANEL = {}

function PANEL:Init()
    self:SetSize(ScrW() * 0.6, ScrH() * 0.7)
    self:Center()
    self:MakePopup()
    self.selectedSkill = nil

    self.header = self:Add("Panel")
    self.header:Dock(TOP)
    self.header:SetTall(50)
    self.header:DockMargin(10, 10, 10, 10)
    self.header.Paint = function(s, w, h)
        local char = LocalPlayer():GetCharacter()
        local points = char and char:GetSkillPoints() or 0
        
        draw.SimpleText("TERMINAL DE MEJORAS", "ixMediumFont", 0, h/2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText("PUNTOS: " .. points, "ixMediumFont", w - 60, h/2, color_accent, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        
        surface.SetDrawColor(color_accent)
        surface.DrawLine(0, h - 1, w, h - 1)
    end

    self.closeBtn = self.header:Add("DButton")
    self.closeBtn:Dock(RIGHT)
    self.closeBtn:SetWide(40)
    self.closeBtn:SetText("X")
    self.closeBtn:SetFont("ixMediumFont")
    self.closeBtn:SetTextColor(color_white)
    
    self.closeBtn.Paint = function(s, w, h)
        local isHovered = s:IsHovered()
        if (isHovered) then
            surface.SetDrawColor(150, 30, 30, 200)
            surface.DrawRect(0, 0, w, h)
        end
        surface.SetDrawColor(isHovered and Color(255, 50, 50) or color_accent_dark)
        surface.DrawOutlinedRect(0, 0, w, h)
    end
    
    self.closeBtn.DoClick = function()
        self:Remove()
    end

    self.body = self:Add("Panel")
    self.body:Dock(FILL)
    self.body:DockMargin(10, 0, 10, 10)

    self.skillList = self.body:Add("DScrollPanel")
    self.skillList:Dock(LEFT)
    self.skillList:SetWide(self:GetWide() * 0.4)
    self.skillList:DockMargin(0, 0, 10, 0)
    
    self.detailsPanel = self.body:Add("Panel")
    self.detailsPanel:Dock(FILL)
    self.detailsPanel.Paint = function(s, w, h)
        surface.SetDrawColor(color_panel_bg)
        surface.DrawRect(0, 0, w, h)
        
        surface.SetDrawColor(color_accent_dark)
        surface.DrawOutlinedRect(0, 0, w, h)
        DrawTechCorners(0, 0, w, h, 15, color_accent)

        if (!self.selectedSkill) then
            draw.SimpleText("SELECCIONA UNA HABILIDAD", "ixSmallFont", w/2, h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

    self:PopulateSkills()
end

function PANEL:PopulateSkills()
    local char = LocalPlayer():GetCharacter()
    if (!char) then return end

    local currentSkills = char:GetSkills() or {}

    for uniqueID, data in pairs(ix.skills.list) do
        local btn = self.skillList:Add("DButton")
        btn:Dock(TOP)
        btn:SetTall(40)
        btn:DockMargin(0, 0, 0, 5)
        btn:SetText("")
        
        local currentLvl = currentSkills[uniqueID] or 0
        
        btn.Paint = function(s, w, h)
            local isHovered = s:IsHovered()
            local isSelected = (self.selectedSkill == uniqueID)

            surface.SetDrawColor(isSelected and color_accent_dark or (isHovered and Color(30, 40, 50, 200) or color_panel_bg))
            surface.DrawRect(0, 0, w, h)
            
            surface.SetDrawColor(isSelected and color_accent or color_accent_dark)
            surface.DrawOutlinedRect(0, 0, w, h)

            draw.SimpleText(data.name, "ixSmallFont", 10, h/2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText("Nvl. " .. currentLvl .. "/" .. data.maxLevel, "ixSmallFont", w - 10, h/2, color_accent, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        end

        btn.DoClick = function()
            self:ShowSkillDetails(uniqueID, data, currentLvl)
        end
    end
end

function PANEL:ShowSkillDetails(uniqueID, data, currentLvl)
    self.selectedSkill = uniqueID
    self.detailsPanel:Clear()

    -- FIX: Añadimos validación estricta de personaje.
    local char = LocalPlayer():GetCharacter()
    if (!char) then return end

    local padding = 20

    local title = self.detailsPanel:Add("DLabel")
    title:Dock(TOP)
    title:DockMargin(padding, padding, padding, 5)
    title:SetFont("ixMediumFont")
    title:SetText(data.name)
    title:SetTextColor(color_accent)

    local levelInfo = self.detailsPanel:Add("DLabel")
    levelInfo:Dock(TOP)
    levelInfo:DockMargin(padding, 0, padding, 15)
    levelInfo:SetFont("ixSmallFont")
    levelInfo:SetText("Nivel Actual: " .. currentLvl .. " / Máximo: " .. data.maxLevel)

    local desc = self.detailsPanel:Add("DLabel")
    desc:Dock(TOP)
    desc:DockMargin(padding, 0, padding, padding)
    desc:SetFont("ixSmallFont")
    desc:SetText(data.description)
    desc:SetWrap(true)
    desc:SetAutoStretchVertical(true)

    local points = char:GetSkillPoints() or 0

    local upgradeBtn = self.detailsPanel:Add("DButton")
    upgradeBtn:Dock(BOTTOM)
    upgradeBtn:DockMargin(padding, padding, padding, padding)
    upgradeBtn:SetTall(40)
    upgradeBtn:SetText("")
    
    local canUpgrade = (points > 0 and currentLvl < data.maxLevel)

    upgradeBtn.Paint = function(s, w, h)
        local bgColor = canUpgrade and (s:IsHovered() and color_accent or color_accent_dark) or Color(50, 50, 50, 100)
        surface.SetDrawColor(bgColor)
        surface.DrawRect(0, 0, w, h)
        
        surface.SetDrawColor(canUpgrade and color_accent or Color(100, 100, 100))
        surface.DrawOutlinedRect(0, 0, w, h)
        
        draw.SimpleText(canUpgrade and "INICIAR MEJORA" or "NO DISPONIBLE", "ixSmallFont", w/2, h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    upgradeBtn.DoClick = function()
        if (canUpgrade) then
            netstream.Start("ixSkillUpgrade", uniqueID)
            self:Remove() -- FIX: Destruye el panel correctamente para evitar el error nil.
        end
    end
end

function PANEL:Paint(w, h)
    ix.util.DrawBlur(self, 5)
    surface.SetDrawColor(color_bg)
    surface.DrawRect(0, 0, w, h)
    
    surface.SetDrawColor(color_accent_dark)
    surface.DrawOutlinedRect(0, 0, w, h)
    DrawTechCorners(0, 0, w, h, 20, color_accent)
end

vgui.Register("ixSkillTreePanel", PANEL, "EditablePanel")