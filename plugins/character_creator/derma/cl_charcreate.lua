local padding = ScreenScale(32)

surface.CreateFont("swrp_tech_title", { font = "Trebuchet MS", size = 18, weight = 800, antialias = true, shadow = true })
surface.CreateFont("swrp_tech_small", { font = "Trebuchet MS", size = 12, weight = 400, antialias = true })
surface.CreateFont("swrp_tech_large", { font = "Trebuchet MS", size = 24, weight = 800, antialias = true, shadow = true })

local COLOR_BG = Color(8, 12, 18, 150)
local COLOR_SLOT = Color(12, 20, 30, 200)
local COLOR_BORDER = Color(30, 80, 120, 100)
local COLOR_BORDER_HOVER = Color(0, 210, 255, 255)
local COLOR_ACCENT = Color(0, 180, 255, 180)
local COLOR_TEXT_TITLE = Color(140, 200, 255, 255)

local function CreateHUDButton(parent, text, onClick, onHover)
	local btn = parent:Add("DButton")
	btn:SetText("")
	btn:SetTall(50)
	btn:Dock(TOP)
	btn:DockMargin(0, 0, 0, 10)
	
	btn.DoClick = onClick
	btn.OnCursorEntered = onHover
	
	btn.Paint = function(self, sw, sh)
		local hover = self:IsHovered()
		draw.RoundedBox(0, 0, 0, sw, sh, hover and Color(0, 210, 255, 25) or COLOR_SLOT)
		surface.SetDrawColor(hover and COLOR_BORDER_HOVER or COLOR_BORDER)
		surface.DrawOutlinedRect(0, 0, sw, sh)
		
		draw.SimpleText(text, "swrp_tech_title", sw/2, sh/2, hover and color_white or COLOR_TEXT_TITLE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		
		if hover then
			local cl, th = 10, 2
			surface.SetDrawColor(COLOR_BORDER_HOVER)
			surface.DrawRect(0, 0, cl, th) surface.DrawRect(0, 0, th, cl)
			surface.DrawRect(sw-cl, 0, cl, th) surface.DrawRect(sw-th, 0, th, cl)
			surface.DrawRect(0, sh-th, cl, th) surface.DrawRect(0, sh-cl, th, cl)
			surface.DrawRect(sw-cl, sh-th, cl, th) surface.DrawRect(sw-th, sh-cl, th, cl)
		end
	end
	return btn
end

DEFINE_BASECLASS("ixCharMenuPanel")
local PANEL = {}

function PANEL:Init()
	BaseClass.Init(self)
	local parent = self:GetParent()
	local listWidth = parent:GetWide() * 0.4
	local previewWidth = parent:GetWide() * 0.6 - (padding * 2)
	local modelFOV = (ScrW() > ScrH() * 1.8) and 100 or 78

	self:ResetPayload(true)
	self.repopulatePanels = {}

	-- PANEL DE PREVISUALIZACIÓN (DERECHA)
	self.previewPanel = self:Add("Panel")
	self.previewPanel:SetSize(previewWidth, parent:GetTall() - (padding * 2))
	self.previewPanel:SetPos(listWidth + padding, padding)
	self.previewPanel.Paint = function(s, sw, sh)
		surface.SetDrawColor(COLOR_SLOT)
		surface.DrawRect(0, 0, sw, sh)
		
		surface.SetDrawColor(0, 0, 0, 50)
		for i = 0, sh, 4 do surface.DrawLine(0, i, sw, i) end
		
		surface.SetDrawColor(0, 0, 0, 220)
		surface.DrawRect(0, 0, sw, 22)
		
		draw.SimpleText("SYS.DATA // INFO", "swrp_tech_small", 4, sh - 14, Color(255,255,255, 15), TEXT_ALIGN_LEFT)
		draw.SimpleText("OP.RDY", "swrp_tech_small", sw - 4, 4, Color(255,255,255, 15), TEXT_ALIGN_RIGHT)
		
		surface.SetDrawColor(COLOR_ACCENT.r, COLOR_ACCENT.g, COLOR_ACCENT.b, 100)
		surface.DrawLine(0, 22, sw, 22)
		
		surface.SetDrawColor(COLOR_BORDER.r, COLOR_BORDER.g, COLOR_BORDER.b, 40)
		surface.DrawOutlinedRect(0, 0, sw, sh)
		
		surface.SetDrawColor(COLOR_ACCENT)
		local cl, th = 15, 2
		surface.DrawRect(0, 0, cl, th) surface.DrawRect(0, 0, th, cl)
		surface.DrawRect(sw-cl, 0, cl, th) surface.DrawRect(sw-th, 0, th, cl)
		surface.DrawRect(0, sh-th, cl, th) surface.DrawRect(0, sh-cl, th, cl)
		surface.DrawRect(sw-cl, sh-th, cl, th) surface.DrawRect(sw-th, sh-cl, th, cl)
	end

	self.previewContent = self.previewPanel:Add("Panel")
	self.previewContent:Dock(FILL)
	self.previewContent:DockMargin(20, 40, 20, 20)

	self.previewTitle = self.previewContent:Add("DLabel")
	self.previewTitle:SetFont("swrp_tech_large")
	self.previewTitle:SetText("")
	self.previewTitle:SetTextColor(COLOR_TEXT_TITLE)
	self.previewTitle:Dock(TOP)
	self.previewTitle:SetTall(40)
	self.previewTitle:SetContentAlignment(5)

	self.previewImage = self.previewContent:Add("DImage")
	self.previewImage:Dock(TOP)
	self.previewImage:SetTall(250)
	self.previewImage:SetVisible(false)

	self.previewModel = self.previewContent:Add("ixModelPanel")
	self.previewModel:Dock(TOP)
	self.previewModel:SetTall(ScrH() * 0.45)
	self.previewModel:SetFOV(modelFOV)
	self.previewModel:SetVisible(false)

	self.previewDesc = self.previewContent:Add("DLabel")
	self.previewDesc:SetFont("swrp_tech_title")
	self.previewDesc:SetText("")
	self.previewDesc:SetTextColor(color_white)
	self.previewDesc:Dock(FILL)
	self.previewDesc:SetWrap(true)
	self.previewDesc:SetContentAlignment(7)
	self.previewDesc:DockMargin(0, 20, 0, 0)

	-- PANEL DE FACCIÓN (IZQUIERDA)
	self.factionPanel = self:AddSubpanel("faction", true)
	self.factionPanel:SetTitle("") 
	
	local titleLabel1 = self.factionPanel:Add("DLabel")
	titleLabel1:SetFont("swrp_tech_large")
	titleLabel1:SetText("ELEGIR FACCIÓN")
	titleLabel1:SetTextColor(COLOR_TEXT_TITLE)
	titleLabel1:Dock(TOP)
	titleLabel1:SetTall(50)

	self.factionButtonsPanel = self.factionPanel:Add("ixCharMenuButtonList")
	self.factionButtonsPanel:SetWide(listWidth)
	self.factionButtonsPanel:Dock(FILL)

	local factionBack = CreateHUDButton(self.factionPanel, "VOLVER", function()
		self:SetActiveSubpanel("faction", 0)
		self:SlideDown()
		parent.mainPanel:Undim()
	end, function() end)
	factionBack:Dock(BOTTOM)

	-- PANEL DE CLASE (IZQUIERDA)
	self.classPanel = self:AddSubpanel("class")
	self.classPanel:SetTitle("")
	
	local titleLabel2 = self.classPanel:Add("DLabel")
	titleLabel2:SetFont("swrp_tech_large")
	titleLabel2:SetText("ELEGIR CLASE")
	titleLabel2:SetTextColor(COLOR_TEXT_TITLE)
	titleLabel2:Dock(TOP)
	titleLabel2:SetTall(50)

	self.classButtonsPanel = self.classPanel:Add("ixCharMenuButtonList")
	self.classButtonsPanel:SetWide(listWidth)
	self.classButtonsPanel:Dock(FILL)

	local classBack = CreateHUDButton(self.classPanel, "VOLVER", function() self:SetActiveSubpanel("faction") end, function() end)
	classBack:Dock(BOTTOM)

	-- PANEL DE KITS (IZQUIERDA)
	self.kitPanel = self:AddSubpanel("kit")
	self.kitPanel:SetTitle("")
	
	local titleLabel3 = self.kitPanel:Add("DLabel")
	titleLabel3:SetFont("swrp_tech_large")
	titleLabel3:SetText("ELEGIR EQUIPAMIENTO")
	titleLabel3:SetTextColor(COLOR_TEXT_TITLE)
	titleLabel3:Dock(TOP)
	titleLabel3:SetTall(50)

	self.kitButtonsPanel = self.kitPanel:Add("ixCharMenuButtonList")
	self.kitButtonsPanel:SetWide(listWidth)
	self.kitButtonsPanel:Dock(FILL)

	local kitBack = CreateHUDButton(self.kitPanel, "VOLVER", function() self:SetActiveSubpanel("class") end, function() end)
	kitBack:Dock(BOTTOM)

	-- PANEL DE DESCRIPCIÓN (IZQUIERDA)
	self.description = self:AddSubpanel("description")
	self.description:SetTitle("")
	
	local titleLabel4 = self.description:Add("DLabel")
	titleLabel4:SetFont("swrp_tech_large")
	titleLabel4:SetText("DATOS DEL PERSONAJE")
	titleLabel4:SetTextColor(COLOR_TEXT_TITLE)
	titleLabel4:Dock(TOP)
	titleLabel4:SetTall(50)

	local descBack = CreateHUDButton(self.description, "VOLVER", function() self:SetActiveSubpanel("kit") end, function() end)
	descBack:Dock(BOTTOM)

	local createBtn = CreateHUDButton(self.description, "FINALIZAR Y CREAR PERSONAJE", function()
		if (self:VerifyProgression("description")) then
			self:SendPayload()
		end
	end, function() end)
	createBtn:Dock(BOTTOM)

	self.descriptionPanel = self.description:Add("DScrollPanel")
	self.descriptionPanel:SetWide(listWidth)
	self.descriptionPanel:Dock(FILL)

	-- EVENTOS DE RED
	net.Receive("ixCharacterAuthed", function()
		timer.Remove("ixCharacterCreateTimeout")
		self.awaitingResponse = false
		local id = net.ReadUInt(32)
		local indices = net.ReadUInt(6)
		local charList = {}
		for _ = 1, indices do charList[#charList + 1] = net.ReadUInt(32) end
		ix.characters = charList
		self:SlideDown()
		if (!IsValid(self) or !IsValid(parent)) then return end
		if (LocalPlayer():GetCharacter()) then
			parent.mainPanel:Undim()
		elseif (id) then
			net.Start("ixCharacterChoose")
			net.WriteUInt(id, 32)
			net.SendToServer()
		else
			self:SlideDown()
		end
	end)
end

function PANEL:Paint(sw, sh)
	ix.util.DrawBlur(self, 10)
	draw.RoundedBox(0, 0, 0, sw, sh, COLOR_BG)
	
	surface.SetDrawColor(COLOR_BORDER.r, COLOR_BORDER.g, COLOR_BORDER.b, 10)
	for i = 0, sw, 64 do surface.DrawLine(i, 0, i, sh) end
	for i = 0, sh, 64 do surface.DrawLine(0, i, sw, i) end
	
	surface.SetDrawColor(COLOR_ACCENT.r, COLOR_ACCENT.g, COLOR_ACCENT.b, 100)
	surface.DrawOutlinedRect(0, 0, sw, sh)
	surface.SetDrawColor(COLOR_ACCENT.r, COLOR_ACCENT.g, COLOR_ACCENT.b, 40)
	surface.DrawOutlinedRect(1, 1, sw - 2, sh - 2)
	
	surface.SetDrawColor(COLOR_ACCENT)
	local cl, th = 30, 4
	surface.DrawRect(0, 0, cl, th) surface.DrawRect(0, 0, th, cl)
	surface.DrawRect(sw-cl, 0, cl, th) surface.DrawRect(sw-th, 0, th, cl)
	surface.DrawRect(0, sh-th, cl, th) surface.DrawRect(0, sh-cl, th, cl)
	surface.DrawRect(sw-cl, sh-th, cl, th) surface.DrawRect(sw-th, sh-cl, th, cl)
end

function PANEL:UpdatePreview(title, desc, image, model)
	self.previewTitle:SetText(L(title):utf8upper())
	self.previewDesc:SetText(desc or "Sin descripción proporcionada.")

	if model then
		local mdl = "models/error.mdl"
		if isstring(model) then
			mdl = model
		elseif istable(model) and isstring(model[1]) then
			mdl = model[1]
		end

		self.previewModel:SetModel(mdl)
		local ent = self.previewModel:GetEntity()
		if IsValid(ent) then
			ent:SetAnimTime(0)
			ent:SetSequence(ent:LookupSequence("idle_unarmed") or 0)
		end

		self.previewModel:SetVisible(true)
		self.previewImage:SetVisible(false)
	elseif image then
		self.previewImage:SetImage(image)
		self.previewImage:SetVisible(true)
		self.previewModel:SetVisible(false)
	else
		self.previewModel:SetVisible(false)
		self.previewImage:SetVisible(false)
	end
end

function PANEL:PopulateClasses(factionID)
	self.classButtonsPanel:Clear()
	local hasClasses = false
	
	for k, v in pairs(ix.class.list) do
		if (v.faction == factionID) then
			hasClasses = true
			CreateHUDButton(self.classButtonsPanel, L(v.name):utf8upper(), function()
				self.payload:Set("class", v.index)
				self:PopulateKits(v.index)
				self:SetActiveSubpanel("kit")
			end, function()
				local mdl = v.model or (v.models and v.models[1])
				self:UpdatePreview(v.name, v.description, v.image, mdl)
			end)
		end
	end
	
	if not hasClasses then
		self.payload:Set("class", "")
		self:PopulateKits("")
		self:SetActiveSubpanel("kit")
	end
end

function PANEL:PopulateKits(classID)
	self.kitButtonsPanel:Clear()
	local kits = ix.kits.GetForClass(classID)
	local hasKits = false

	for k, v in pairs(kits) do
		hasKits = true
		CreateHUDButton(self.kitButtonsPanel, L(v.name):utf8upper(), function()
			self.payload:Set("kit", k)
			self:SetActiveSubpanel("description")
		end, function()
			self:UpdatePreview(v.name, v.description, v.image, v.model or "models/error.mdl")
		end)
	end
	
	if not hasKits then
		CreateHUDButton(self.kitButtonsPanel, "ESTÁNDAR (SIN KIT)", function()
			self.payload:Set("kit", "")
			self:SetActiveSubpanel("description")
		end, function()
			self:UpdatePreview("Sin Kit", "No hay equipamiento disponible para esta clase.", nil, nil)
		end)
	end
end

function PANEL:Populate()
	if (!self.bInitialPopulate) then
		self.factionButtonsPanel:Clear()

		for _, v in SortedPairs(ix.faction.teams) do
			if (ix.faction.HasWhitelist(v.index)) then
				CreateHUDButton(self.factionButtonsPanel, L(v.name):utf8upper(), function(panel)
					self.payload:Set("faction", v.index)
					
					-- Fix: Asignar un modelo por defecto para que pase la validación interna de Helix
					local models = v:GetModels(LocalPlayer())
					if models and #models > 0 then
						self.payload:Set("model", 1)
					end

					self:PopulateClasses(v.index)
					self:SetActiveSubpanel("class")
				end, function()
					local firstModel = v.models and v.models[1]
					self:UpdatePreview(v.name, v.description, v.image, firstModel)
				end)
			end
		end
	end

	for i = 1, #self.repopulatePanels do
		self.repopulatePanels[i]:Remove()
	end
	self.repopulatePanels = {}

	local bWasNil = false
	if not self.payload.faction then
		local _, firstFaction = next(ix.faction.indices)
		if firstFaction then
			self.payload.faction = firstFaction.index
			bWasNil = true
		end
	end

	local zPos = 1
	for k, v in SortedPairsByMemberValue(ix.char.vars, "index") do
		if (!v.bNoDisplay and k != "__SortedIndex") then
			local container = self.descriptionPanel
			if (v.ShouldDisplay and v:ShouldDisplay(container, self.payload) == false) then continue end

			local panel
			if (v.OnDisplay) then
				panel = v:OnDisplay(container, self.payload)
			elseif (isstring(v.default)) then
				panel = container:Add("ixTextEntry")
				panel:Dock(TOP)
				panel:SetFont("ixMenuButtonHugeFont")
				panel:SetUpdateOnType(true)
				panel.OnValueChange = function(this, text)
					self.payload:Set(k, text)
				end
			end

			if (IsValid(panel)) then
				local label = container:Add("DLabel")
				label:SetFont("swrp_tech_title")
				label:SetTextColor(COLOR_TEXT_TITLE)
				label:SetText(L(k):utf8upper())
				label:SizeToContents()
				label:DockMargin(0, 16, 0, 2)
				label:Dock(TOP)
				label:SetZPos(zPos - 1)
				panel:SetZPos(zPos)
				self:AttachCleanup(label)
				self:AttachCleanup(panel)
				if (v.OnPostSetup) then v:OnPostSetup(panel, self.payload) end
				zPos = zPos + 2
			end
		end
	end

	if bWasNil then
		self.payload.faction = nil
	end

	self.bInitialPopulate = true
end

function PANEL:GetContainerPanel(name)
	return self.descriptionPanel
end

function PANEL:AttachCleanup(panel)
	self.repopulatePanels[#self.repopulatePanels + 1] = panel
end

function PANEL:VerifyProgression(name)
	for k, v in SortedPairsByMemberValue(ix.char.vars, "index") do
		local value = self.payload[k]
		if (!v.bNoDisplay or v.OnValidate) then
			if (v.OnValidate) then
				local result = {v:OnValidate(value, self.payload, LocalPlayer())}
				if (result[1] == false) then
					self:GetParent():ShowNotice(3, L(unpack(result, 2)))
					return false
				end
			end
			self.payload[k] = value
		end
	end
	return true
end

function PANEL:SendPayload()
	if (self.awaitingResponse or !self:VerifyProgression()) then return end
	self.awaitingResponse = true
	self.payload:Prepare()

	net.Start("ixCharacterCreate")
	net.WriteUInt(table.Count(self.payload), 8)
	for k, v in pairs(self.payload) do
		net.WriteString(k)
		net.WriteType(v)
	end
	net.SendToServer()
end

function PANEL:OnSlideUp()
	self:ResetPayload()
	self:Populate()
	self:SetActiveSubpanel("faction", 0)
	
	self.previewTitle:SetText("")
	self.previewDesc:SetText("")
	self.previewImage:SetVisible(false)
	self.previewModel:SetVisible(false)
end

function PANEL:ResetPayload(bWithHooks)
	if (bWithHooks) then self.hooks = {} end
	self.payload = {}
	function self.payload.Set(payload, key, value) self:SetPayload(key, value) end
	function self.payload.AddHook(payload, key, callback) self:AddPayloadHook(key, callback) end
	function self.payload.Prepare(payload)
		self.payload.Set = nil
		self.payload.AddHook = nil
		self.payload.Prepare = nil
	end
end

function PANEL:SetPayload(key, value)
	self.payload[key] = value
	self:RunPayloadHook(key, value)
end

function PANEL:AddPayloadHook(key, callback)
	if (!self.hooks[key]) then self.hooks[key] = {} end
	self.hooks[key][#self.hooks[key] + 1] = callback
end

function PANEL:RunPayloadHook(key, value)
	local hooks = self.hooks[key] or {}
	for _, v in ipairs(hooks) do v(value) end
end

vgui.Register("ixCharMenuNew", PANEL, "ixCharMenuPanel")
