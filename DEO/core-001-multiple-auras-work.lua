-- ToDo
-- verify cd time is accurate

DEO = LibStub("AceAddon-3.0"):NewAddon("DEO", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0")
local function p(str)
	DEO:Print(ChatFrame4, str)
end
function DEO:OnInitialize()
	DEO:Print(ChatFrame4, "Loaded.")
	
	-- Aura Properties
	DEOTracking = {}
	DEOTracking["Mark of Bleeding Hollow"] = {
		-- Manually set
		icon = "spell_shadow_demonictactics",
		cd = 26,
		isRPPM = false,
	}
	DEOTracking["Instability"] = {
		-- Manually set
		icon = "inv_misc_trinket6oih_orb2",
		cd = 65,
		isRPPM = false,
	}
	
	-- Creating IDs, IconPath, buff
	local n = 0	
	for key,val in pairs(DEOTracking) do
		--DEOTracking[key].id = "DEO".. DEOTracking[key].buff:gsub('%W','')
		DEOTracking[key].id = "DEO".. key:gsub('%W','')
		DEOTracking[key].buff = "DEO".. key
		DEOTracking[key].iconPathAvail = "Interface\\Icons\\".. DEOTracking[key].icon
		DEOTracking[key].auraPosition = n
		n = n + 1
	end
	
	-- Creating Container
	DEOContainer = CreateFrame("FRAME", "DEOContainer", UIParent)
	DEOContainer:SetPoint("CENTER",-66,-525)
	DEOContainer:SetWidth(1000)
	DEOContainer:SetHeight(1000)
	
	-- Creating Auras
	
	local parent = DEOContainer
	for key,val in pairs(DEOTracking) do
		_G[DEOTracking[key].id] = DEO:Create(DEOTracking[key],parent)
		_G[DEOTracking[key].id]:SetScale(UIParent:GetEffectiveScale())
		DEO:SetState(_G[DEOTracking[key].id])
		DEO:Print(ChatFrame4, "Created: ", _G[DEOTracking[key].id].id)
	end
end
function DEO:Create(data, parent)
	-- DEOContainer > aura - Aura is the the item we are tracking
    local aura = CreateFrame("FRAME", data.id .. "Aura", parent)
	aura.auraPosition = data.auraPosition
	aura:SetPoint("CENTER",42*aura.auraPosition,0)
	aura:SetWidth(36)
	aura:SetHeight(36)
	
	-- DEOContainer > aura > icon - Icon of the spell
    local icon = aura:CreateTexture(nil, "BACKGROUND")
    aura.icon = icon
	icon:SetAllPoints(aura)   
    --icon:SetTexture("Interface\\Icons\\" .. data.iconNameAvail)
	
	-- DEOContainer > aura > buttonBorder - Border, actually on top of the Icon
	local buttonBorder = aura:CreateTexture(nil, "ARTWORK")
	aura.buttonBorder = buttonBorder
	buttonBorder:SetPoint("CENTER",0,0)
	buttonBorder:SetWidth(66)
	buttonBorder:SetHeight(66)
	buttonBorder:SetTexture("Interface\\Buttons\\UI-Quickslot2");	
	
	-- DEOContainer > aura > cooldown - Cooldown Sweep
    local cooldown = CreateFrame("COOLDOWN", nil, aura, "CooldownFrameTemplate")
    aura.cooldown = cooldown
    cooldown:SetAllPoints(icon)
    cooldown:SetDrawEdge(false)

	-- DEOContainer > aura > cooldown > textFrame > text - Text for when item is active
    local textFrame = CreateFrame("frame", nil, aura)
    textFrame:SetFrameLevel(cooldown:GetFrameLevel() + 1)
    local text = textFrame:CreateFontString(nil, "OVERLAY")
    aura.text = text
	aura.text:SetFont("Fonts\\FRIZQT__.TTF",14,"OUTLINE")
	aura.text:SetAllPoints(icon)
	
	aura.id = data.id
	aura.buff = data.buff
	aura.iconPathUp = ""
	aura.iconPathAvail = data.iconPathAvail
	aura.cd = data.cd
	aura.isRPPM = data.isRPPM
	aura.state = "avail"
	aura.duration = 0
	aura.expirationTime = math.huge
	aura.timeStamp = math.huge
	
	return aura
end

function DEO:COMBAT_LOG_EVENT_UNFILTERED(...)
	local event, timeStamp, subevent, _, sguid, sname, _, _, dguid, dname, _, _, spid, spname = ...
	if dguid == UnitGUID("player") then
		local isSpellTracked = _G["DEOTracking"][spname] ~= nil
        if subevent == "SPELL_AURA_APPLIED" or subevent == "SPELL_AURA_REFRESH" then
            if isSpellTracked then
				local auraName = "DEO"..spname:gsub('%W','')
                local _, _, icon, _, _, duration, expirationTime = UnitAura("player",spname)		
			 -- _G["DEO"..spname:gsub('%W','')].timeStamp = timeStamp
				_G[auraName].iconPathUp =  icon
				_G[auraName].duration = duration
				_G[auraName].expirationTime = expirationTime				
				_G[auraName].state = "up"
				DEO:SetState(_G[auraName])
			end
		elseif subevent == "SPELL_AURA_REMOVED" then
			if isSpellTracked then
				local auraName = "DEO"..spname:gsub('%W','')
				_G[auraName].state = "cd"
				DEO:SetState(_G[auraName])
			end
		end			
	end	
	
end	
function DEO:SetState(aura)
	
	local state = aura.state
	local function UpdateTime()
		aura.text:SetText(string.format("%.f",aura.expirationTime-GetTime()))
	end
	-------------
	-- STATE: up
	-------------	
	if state == "up" then
		aura.icon:SetTexture(aura.iconPathUp)
		LibStub("LibButtonGlow-1.0").ShowOverlayGlow(aura);
		aura.cooldown:SetCooldown(aura.expirationTime - aura.duration, aura.cd)
		aura:SetScript("OnUpdate", UpdateTime)
	else
		LibStub("LibButtonGlow-1.0").HideOverlayGlow(aura)
		aura:SetScript("OnUpdate", nil)
		aura.text:SetText("")
	end
	-------------
	-- STATE: cd
	-------------
	if state == "cd" then
		aura.cooldown:Show()
	else
		aura.cooldown:Hide()
	end
	-------------
	-- STATE: avail
	-------------	
	if state == "avail" then
		aura.icon:SetTexture(aura.iconPathAvail)				
	else
	end
	-- optional changes
	-- aura.icon:SetVertexColor(1,1,1,1)
	-- desaturate
	-- update icon
end
function DEO:OnDisable()
    -- Called when the addon is disabled
end
	
	
	
	
DEO:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")