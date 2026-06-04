-- ============================================================
-- Character Creator UI - Mejorado con selector de Skin 3D
-- Autor: Antigravity (modificado)
-- ============================================================

local padding = ScreenScale(32)

surface.CreateFont("swrp_tech_title", { font = "Trebuchet MS", size = 18, weight = 800, antialias = true, shadow = true })
surface.CreateFont("swrp_tech_small", { font = "Trebuchet MS", size = 12, weight = 400, antialias = true })
surface.CreateFont("swrp_tech_large", { font = "Trebuchet MS", size = 24, weight = 800, antialias = true, shadow = true })
surface.CreateFont("swrp_tech_skin_nav", { font = "Trebuchet MS", size = 22, weight = 900, antialias = true })

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

-- ============================================================
-- SKIN SELECTOR: Visor 3D con navegación de skins
-- ============================================================
-- Crea un panel que muestra el modelo 3D con botones ◄ ►
-- para cambiar entre los modelos/skins de la clase seleccionada.
-- skinList: tabla de strings (rutas de modelos)
-- onSkinChosen: callback(skinIndex, modelPath) al confirmar
-- ============================================================
local function CreateSkinSelector(parent, skinList, currentIndex, onSkinChosen)
	-- Limpiar selector anterior si existe
	if IsValid(parent.skinSelectorPanel) then
		parent.skinSelectorPanel:Remove()
	end

	if not skinList or #skinList == 0 then return end

	local idx = currentIndex or 1
	idx = math.Clamp(idx, 1, #skinList)

	-- Panel contenedor principal
	local selectorPanel = parent:Add("Panel")
	selectorPanel:Dock(FILL)
	selectorPanel:DockMargin(0, 8, 0, 0)
	parent.skinSelectorPanel = selectorPanel

	selectorPanel.Paint = function(s, sw, sh)
		-- Fondo HUD
		surface.SetDrawColor(COLOR_SLOT)
		surface.DrawRect(0, 0, sw, sh)
		surface.SetDrawColor(0, 0, 0, 40)
		for i = 0, sh, 4 do surface.DrawLine(0, i, sw, i) end
		surface.SetDrawColor(COLOR_ACCENT.r, COLOR_ACCENT.g, COLOR_ACCENT.b, 60)
		surface.DrawOutlinedRect(0, 0, sw, sh)
		-- Esquinas
		surface.SetDrawColor(COLOR_ACCENT)
		local cl, th = 12, 2
		surface.DrawRect(0, 0, cl, th) surface.DrawRect(0, 0, th, cl)
		surface.DrawRect(sw-cl, 0, cl, th) surface.DrawRect(sw-th, 0, th, cl)
		surface.DrawRect(0, sh-th, cl, th) surface.DrawRect(0, sh-cl, th, cl)
		surface.DrawRect(sw-cl, sh-th, cl, th) surface.DrawRect(sw-th, sh-cl, th, cl)
	end

	-- Header con label
	local header = selectorPanel:Add("DLabel")
	header:SetFont("swrp_tech_small")
	header:SetText("SKIN // ASPECTO VISUAL")
	header:SetTextColor(Color(255, 255, 255, 30))
	header:Dock(TOP)
	header:SetTall(20)
	header:SetContentAlignment(5)
	header:DockMargin(0, 4, 0, 0)

	-- Fila de navegación (◄ MODEL N/TOTAL ►)
	local navRow = selectorPanel:Add("Panel")
	navRow:Dock(TOP)
	navRow:SetTall(36)
	navRow:DockMargin(8, 4, 8, 0)
	navRow.Paint = function() end

	local btnPrev = navRow:Add("DButton")
	btnPrev:SetText("◄")
	btnPrev:SetFont("swrp_tech_skin_nav")
	btnPrev:SetWide(40)
	btnPrev:Dock(LEFT)
	btnPrev.Paint = function(self, sw, sh)
		local hover = self:IsHovered()
		draw.RoundedBox(0, 0, 0, sw, sh, hover and Color(0, 210, 255, 30) or Color(0,0,0,0))
		surface.SetDrawColor(hover and COLOR_BORDER_HOVER or COLOR_BORDER)
		surface.DrawOutlinedRect(0, 0, sw, sh)
		draw.SimpleText("◄", "swrp_tech_skin_nav", sw/2, sh/2, hover and color_white or COLOR_TEXT_TITLE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	local counterLabel = navRow:Add("DLabel")
	counterLabel:Dock(FILL)
	counterLabel:SetFont("swrp_tech_title")
	counterLabel:SetTextColor(COLOR_TEXT_TITLE)
	counterLabel:SetContentAlignment(5)

	local btnNext = navRow:Add("DButton")
	btnNext:SetText("►")
	btnNext:SetFont("swrp_tech_skin_nav")
	btnNext:SetWide(40)
	btnNext:Dock(RIGHT)
	btnNext.Paint = function(self, sw, sh)
		local hover = self:IsHovered()
		draw.RoundedBox(0, 0, 0, sw, sh, hover and Color(0, 210, 255, 30) or Color(0,0,0,0))
		surface.SetDrawColor(hover and COLOR_BORDER_HOVER or COLOR_BORDER)
		surface.DrawOutlinedRect(0, 0, sw, sh)
		draw.SimpleText("►", "swrp_tech_skin_nav", sw/2, sh/2, hover and color_white or COLOR_TEXT_TITLE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	-- Panel del modelo 3D
	-- Alto suficiente para ver el personaje entero de cuerpo completo
	local modelHeight = math.max(280, math.min(420, ScrH() * 0.38))
	local modelContainer = selectorPanel:Add("Panel")
	modelContainer:Dock(TOP)
	modelContainer:SetTall(modelHeight)
	modelContainer:DockMargin(8, 6, 8, 0)
	modelContainer.Paint = function(s, sw, sh)
		surface.SetDrawColor(0, 5, 15, 180)
		surface.DrawRect(0, 0, sw, sh)
		-- Líneas de escaneo
		surface.SetDrawColor(0, 180, 255, 6)
		for i = 0, sh, 3 do surface.DrawLine(0, i, sw, i) end
		-- Borde interior
		surface.SetDrawColor(COLOR_BORDER)
		surface.DrawOutlinedRect(0, 0, sw, sh)
		-- Texto de modo
		draw.SimpleText("HOLO.DISPLAY", "swrp_tech_small", sw - 6, sh - 14, Color(0, 180, 255, 25), TEXT_ALIGN_RIGHT)
		-- Hint de drag
		draw.SimpleText("[ ARRASTRAR PARA ROTAR ]", "swrp_tech_small", sw / 2, sh - 14, Color(0, 180, 255, 18), TEXT_ALIGN_CENTER)
	end

	-- DModelPanel con control total de cámara
	local isDragging = false
	local lastMouseX = 0
	local skinAngle = 0
	local animApplied = false
	local currentMdl = ""
	-- Zoom: distancia de la cámara al modelo. Empieza lejos para ver el cuerpo entero.
	local camDist   = 400
	local CAM_MIN   = 30
	local CAM_MAX   = 400
	local ZOOM_STEP = 10
	-- Posición del punto al que mira la cámara (pan con RMB)
	local camOffsetY = 0   -- desplazamiento horizontal (izq/der)
	local camOffsetZ = 40  -- desplazamiento vertical   (arriba/abajo) — equivale al antiguo CAM_HEIGHT
	local PAN_SPEED  = 0.3 -- sensibilidad del pan

	local mdlPanel = modelContainer:Add("DModelPanel")
	mdlPanel:Dock(FILL)
	mdlPanel:DockMargin(2, 2, 2, 2)
	mdlPanel:SetFOV(50)
	mdlPanel:SetCamPos(Vector(camDist, camOffsetY, camOffsetZ))
	mdlPanel:SetLookAt(Vector(0, camOffsetY, camOffsetZ))
	mdlPanel:SetMouseInputEnabled(true)   -- necesario para scroll, drag y pan

	-- LMB = rotar | RMB = pan (mover punto de mira)
	local isPanning = false
	local lastPanX, lastPanY = 0, 0

	mdlPanel.OnMousePressed = function(self, code)
		if code == MOUSE_LEFT then
			isDragging = true
			lastMouseX = gui.MouseX()
		elseif code == MOUSE_RIGHT then
			isPanning = true
			lastPanX = gui.MouseX()
			lastPanY = gui.MouseY()
		end
	end
	mdlPanel.OnMouseReleased = function(self, code)
		if code == MOUSE_LEFT then isDragging = false end
		if code == MOUSE_RIGHT then isPanning = false end
	end

	-- Zoom con scroll
	mdlPanel.OnMouseWheeled = function(self, delta)
		camDist = math.Clamp(camDist - delta * ZOOM_STEP, CAM_MIN, CAM_MAX)
		self:SetCamPos(Vector(camDist, camOffsetY, camOffsetZ))
		self:SetLookAt(Vector(0, camOffsetY, camOffsetZ))
		return true
	end

	function mdlPanel:LayoutEntity(ent)
		-- Aplicar animación UNA sola vez cuando el modelo carga
		if not animApplied then
			-- Probar secuencias en orden de preferencia hasta encontrar una válida
			local seqNames = {
				"idle_unarmed", "idle", "walk_all", "walk",
				"stand_all", "stand", "idle_angry", "ref_aim_standing"
			}
			local seq = -1
			for _, name in ipairs(seqNames) do
				local s = ent:LookupSequence(name)
				if s and s >= 0 then seq = s break end
			end
			if seq < 0 then seq = 0 end  -- último recurso: secuencia 0
			ent:ResetSequence(seq)
			ent:SetPlaybackRate(1)
			animApplied = true
		end
		-- LMB: rotar
		if isDragging then
			local dx = gui.MouseX() - lastMouseX
			skinAngle = skinAngle + dx * 0.6
			lastMouseX = gui.MouseX()
		end
		-- RMB: pan (desplazar punto de mira)
		if isPanning then
			local dx = gui.MouseX() - lastPanX
			local dy = gui.MouseY() - lastPanY
			camOffsetY = camOffsetY - dx * PAN_SPEED
			camOffsetZ = camOffsetZ + dy * PAN_SPEED
			lastPanX = gui.MouseX()
			lastPanY = gui.MouseY()
			self:SetCamPos(Vector(camDist, camOffsetY, camOffsetZ))
			self:SetLookAt(Vector(0, camOffsetY, camOffsetZ))
		end
		ent:SetAngles(Angle(0, skinAngle, 0))
	end

	-- Dot indicators (puntitos de páginas)
	local dotsRow = selectorPanel:Add("Panel")
	dotsRow:Dock(TOP)
	dotsRow:SetTall(16)
	dotsRow:DockMargin(0, 6, 0, 0)
	dotsRow.Paint = function() end

	-- Helper: dibujar dots
	local function RefreshDots()
		dotsRow:Clear()
		local total = #skinList
		local dotSize = 8
		local dotGap = 5
		local totalW = total * dotSize + (total - 1) * dotGap
		local startX = (dotsRow:GetWide() - totalW) / 2
		-- Usamos un panel pintado para los dots
		local dotPainter = dotsRow:Add("Panel")
		dotPainter:SetPos(startX, 4)
		dotPainter:SetSize(totalW, dotSize)
		dotPainter.Paint = function(self, sw, sh)
			for i = 1, total do
				local x = (i-1) * (dotSize + dotGap)
				local active = (i == idx)
				surface.SetDrawColor(active and COLOR_BORDER_HOVER or COLOR_BORDER)
				surface.DrawRect(x, 0, dotSize, dotSize)
				if active then
					surface.SetDrawColor(COLOR_ACCENT.r, COLOR_ACCENT.g, COLOR_ACCENT.b, 40)
					for g = 1, 3 do
						surface.DrawOutlinedRect(x - g, -g, dotSize + g*2, dotSize + g*2)
					end
				end
			end
		end
	end

	-- Helper: actualizar modelo mostrado
	local function SetSkinIndex(newIdx)
		idx = math.Clamp(newIdx, 1, #skinList)
		local mdl = skinList[idx]
		if currentMdl ~= mdl then
			currentMdl = mdl
			mdlPanel:SetModel(mdl)
			animApplied = false   -- forzar reaplicación de animación al nuevo modelo
			skinAngle = 0         -- resetear rotación
			camDist    = CAM_MAX  -- resetear zoom
			camOffsetY = 0        -- resetear pan horizontal
			camOffsetZ = 40       -- resetear pan vertical al valor inicial
			mdlPanel:SetCamPos(Vector(camDist, camOffsetY, camOffsetZ))
			mdlPanel:SetLookAt(Vector(0, camOffsetY, camOffsetZ))
		end
		counterLabel:SetText("SKIN " .. idx .. " / " .. #skinList)
		RefreshDots()
		if onSkinChosen then
			onSkinChosen(idx, skinList[idx])
		end
	end

	btnPrev.DoClick = function()
		SetSkinIndex(idx - 1 < 1 and #skinList or idx - 1)
	end
	btnNext.DoClick = function()
		SetSkinIndex(idx + 1 > #skinList and 1 or idx + 1)
	end

	-- Inicializar
	SetSkinIndex(idx)

	return selectorPanel
end

-- ============================================================
-- PANEL PRINCIPAL
-- ============================================================

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

	-- Modelo 3D principal (usado en facción y kit hover)
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

	-- ============================================================
	-- PANEL DE CLASE (IZQUIERDA) - Con selector de skin 3D
	-- ============================================================
	self.classPanel = self:AddSubpanel("class")
	self.classPanel:SetTitle("")
	
	local titleLabel2 = self.classPanel:Add("DLabel")
	titleLabel2:SetFont("swrp_tech_large")
	titleLabel2:SetText("ELEGIR CLASE")
	titleLabel2:SetTextColor(COLOR_TEXT_TITLE)
	titleLabel2:Dock(TOP)
	titleLabel2:SetTall(50)

	-- Botones de clase
	self.classButtonsPanel = self.classPanel:Add("ixCharMenuButtonList")
	self.classButtonsPanel:SetWide(listWidth)
	self.classButtonsPanel:Dock(TOP)
	self.classButtonsPanel:SetTall(0) -- se ajusta dinámicamente

	-- Contenedor del skin selector (dentro del panel clase)
	self.skinSelectorContainer = self.classPanel:Add("Panel")
	self.skinSelectorContainer:Dock(FILL)
	self.skinSelectorContainer:DockMargin(0, 6, 0, 0)
	self.skinSelectorContainer.Paint = function() end
	self.skinSelectorContainer:SetVisible(false)

	-- Label "SELECCIONA SKIN"
	local skinHeaderLabel = self.skinSelectorContainer:Add("DLabel")
	skinHeaderLabel:SetFont("swrp_tech_title")
	skinHeaderLabel:SetTextColor(COLOR_TEXT_TITLE)
	skinHeaderLabel:SetText("SELECCIONA ASPECTO")
	skinHeaderLabel:Dock(TOP)
	skinHeaderLabel:SetTall(30)
	skinHeaderLabel:SetContentAlignment(5)
	skinHeaderLabel:DockMargin(0, 0, 0, 4)

	-- Aquí se inyecta el skin selector
	self.skinSelectorArea = self.skinSelectorContainer:Add("Panel")
	self.skinSelectorArea:Dock(FILL)
	self.skinSelectorArea.Paint = function() end

	local classBack = CreateHUDButton(self.classPanel, "VOLVER", function()
		self:SetActiveSubpanel("faction")
		self.skinSelectorContainer:SetVisible(false)
	end, function() end)
	classBack:Dock(BOTTOM)

	-- Botón "CONTINUAR" (aparece solo cuando se selecciona clase con skins)
	self.classContinueBtn = CreateHUDButton(self.classPanel, "CONTINUAR →", function()
		self:PopulateKits(self.selectedClassIndex)
		self:SetActiveSubpanel("kit")
	end, function() end)
	self.classContinueBtn:Dock(BOTTOM)
	self.classContinueBtn:DockMargin(0, 0, 0, 6)
	self.classContinueBtn:SetVisible(false)

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

-- ============================================================
-- HELPER: Obtener lista de modelos de una clase
-- Soporta v.model (string), v.models (tabla) y v.playermodels (tabla)
-- ============================================================
local function GetClassModels(classData)
	if istable(classData.models) and #classData.models > 0 then
		return classData.models
	elseif istable(classData.playermodels) and #classData.playermodels > 0 then
		return classData.playermodels
	elseif isstring(classData.model) and classData.model != "" then
		return { classData.model }
	end
	return {}
end

-- ============================================================
-- POPULATE CLASSES - Ahora muestra selector de skin al hacer click
-- ============================================================
function PANEL:PopulateClasses(factionID)
	self.classButtonsPanel:Clear()
	self.skinSelectorContainer:SetVisible(false)
	self.classContinueBtn:SetVisible(false)
	local hasClasses = false
	
	-- Calcular altura dinámica de botones de clase
	local classCount = 0
	for k, v in pairs(ix.class.list) do
		if (v.faction == factionID) then classCount = classCount + 1 end
	end
	-- Máximo 2 botones visibles antes de scroll, para dejar espacio al visor 3D
	local btnH = 60 -- 50 tall + 10 margin
	local maxH = math.min(classCount * btnH, 2 * btnH)
	self.classButtonsPanel:SetTall(maxH)

	for k, v in pairs(ix.class.list) do
		if (v.faction == factionID) then
			hasClasses = true
			local classModels = GetClassModels(v)
			local hasMultipleSkins = #classModels > 1

			-- Texto del botón indica si hay múltiples skins
			local btnText = L(v.name):utf8upper()
			if hasMultipleSkins then
				btnText = btnText .. "  [" .. #classModels .. " SKINS]"
			end

			CreateHUDButton(self.classButtonsPanel, btnText, function()
				-- Al hacer click: seleccionar clase y mostrar skin selector
				self.payload:Set("class", v.index)
				self.selectedClassIndex = v.index

				-- Actualizar preview principal con descripción
				self:UpdatePreview(v.name, v.description, v.image, classModels[1] or v.model)

				if hasMultipleSkins then
					-- Mostrar selector de skin embebido en el panel clase
					self.skinSelectorContainer:SetVisible(true)
					self.classContinueBtn:SetVisible(true)

					-- Limpiar área anterior
					self.skinSelectorArea:Clear()

					-- Crear el skin selector
					local initialSkin = self.selectedSkinIndex or 1
					CreateSkinSelector(self.skinSelectorArea, classModels, initialSkin, function(skinIdx, modelPath)
						-- Guardar la skin elegida en el payload
						self.selectedSkinIndex = skinIdx
						self.payload:Set("model", skinIdx)
						-- Sincronizar el modelo grande del preview derecho
						self:UpdatePreview(v.name, v.description, v.image, modelPath)
					end)
				else
					-- Una sola skin: ir directo a kits
					self.skinSelectorContainer:SetVisible(false)
					self.classContinueBtn:SetVisible(false)
					if #classModels == 1 then
						self.payload:Set("model", 1)
					end
					self:PopulateKits(v.index)
					self:SetActiveSubpanel("kit")
				end
			end, function()
				-- Hover: mostrar preview del primer modelo
				local mdl = classModels[1] or v.model
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
	self.skinSelectorContainer:SetVisible(false)
	self.classContinueBtn:SetVisible(false)
	self.selectedSkinIndex = 1
	self.selectedClassIndex = nil
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