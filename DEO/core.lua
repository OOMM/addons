DEO = LibStub("AceAddon-3.0"):NewAddon("DEO", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0")
local function p(str)
	DEO:Print(ChatFrame4, str)
end
function DEO:OnInitialize()
	DEO:Print(ChatFrame4, "Loaded.")
	
  --if _G.StanceBarFrame 
  
	-- Aura Properties
	DEOTracking = {}
	-- Enchant
	DEOTracking["Mark of Bleeding Hollow"] = { spid = 173322, cd = 0, rppm = 2.3, originType = "enchant", slot = 16}
	-- Equipment
	DEOTracking["Howling Soul"] = { spid = 177046, rppm = 0.92, originType = "equipment", itemid = 119194}
	DEOTracking["Archmage's Greater Incandescence"] = { spid = 177176, rppm = 0.92, originType = "equipment", itemid = 118306}
	DEOTracking["Instability"] = { spid = 177051, rppm = 0.92, originType = "equipment", itemid = 113948, originIcon = "spell_shadow_demonform"}
	DEOTracking["Nightmare Fire"] = { spid = 162919, cd = 115, originType = "equipment", itemid = 112320}
	-- Item
	--DEOTracking["Draenic Intellect Potion"] = { spid = 156426, originType = "item", itemid = 109218}
	-- Heroism - special case
	--DEOTracking["Heroism"] = { spid = {32182}, spidDebuff = 57723, originType = "heroism",}
	--p(DEOTracking["Heroism"]["spid"][1])
	
	-- Getting Rings and Trinkets
	local equipped = {}
	local itemid = 0
	for slot=11,14,1 do
		itemid = GetInventoryItemID("player", slot) or 0
		equipped[itemid] = true
	end
	
	-- Build IDs, IconPath, buff, rppm - make sure each of these is assigned within DEO:Create
	local n = 0	
	for key,val in pairs(DEOTracking) do

		-- Is Enabled?
		if (DEOTracking[key].originType ~= "equipment") then 
			DEOTracking[key].enabled = true
		elseif (DEOTracking[key].originType == "equipment") and (equipped[DEOTracking[key].itemid] ~= nil) then
			DEOTracking[key].enabled = true
			DEOTracking[key].equipmentIcon = GetItemIcon(DEOTracking[key].itemid)
		else
			DEOTracking[key].enabled = false
		end
		if DEOTracking[key].enabled then
			DEOTracking[key].auraPosition = n
			n = n + 1
			
			-- Base Icon
			if DEOTracking[key].originIcon ~= nil then
				DEOTracking[key].iconPathAvail = "Interface\\Icons\\".. DEOTracking[key].originIcon
			elseif DEOTracking[key].equipmentIcon ~= nil then
				DEOTracking[key].iconPathAvail = DEOTracking[key].equipmentIcon
			elseif DEOTracking[key].slot ~= nil then
				DEOTracking[key].iconPathAvail = GetItemIcon(GetInventoryItemID("player", DEOTracking[key].slot))				
			else
				if GetSpellInfo(DEOTracking[key].spid) then
					_, _, DEOTracking[key].iconPathAvail = GetSpellInfo(DEOTracking[key].spid)
				else 
					_, _, DEOTracking[key].iconPathAvail = GetSpellInfo(DEOTracking[key].spid[1])
				end
			end
			
			-- Buff Name
			DEOTracking[key].buff = "DEO".. key
			
			-- ID (Buff Name aZ)
			DEOTracking[key].id = "DEO".. key:gsub('%W','')
			
			-- RPPM into Cooldown
			if nil == DEOTracking[key].cd and nil == DEOTracking[key].spidDebuff and DEOTracking[key].rppm ~= 0 then
				DEOTracking[key].cd = 60/DEOTracking[key].rppm
			end
			
		end
	end
	
  -- Creating, Positioning Container - Checks position of Stance and Pet bars to determine y position

	DEOContainer = CreateFrame("FRAME", "DEOContainer", UIParent)
	DEOContainer:SetPoint("RIGHT",_G.MultiBarBottomRight,"LEFT",0,0)
	DEOContainer:SetWidth(42*4)
	DEOContainer:SetHeight(66)

	-- Creating Auras
	local parent = DEOContainer
	for key,val in pairs(DEOTracking) do
		if DEOTracking[key].enabled then
			_G[DEOTracking[key].id] = DEO:Create(DEOTracking[key],parent)
			_G[DEOTracking[key].id]:SetScale(UIParent:GetEffectiveScale())
			_G[DEOTracking[key].id]:SetScale(UIParent:GetEffectiveScale()*.8)
			DEO:SetState(_G[DEOTracking[key].id])
			DEO:Print(ChatFrame4, "Created: ", _G[DEOTracking[key].id].id)
		end
	end
end

function DEO:Create(data, parent)
	-- DEOContainer > aura - Aura is the the item we are tracking
  local aura = CreateFrame("FRAME", data.id .. "Aura", parent)
	aura.auraPosition = data.auraPosition
	aura:SetPoint("RIGHT",-42*aura.auraPosition,0)
	aura:SetWidth(38)
	aura:SetHeight(38)
	
	-- DEOContainer > aura > icon - Icon of the spell
  local icon = aura:CreateTexture(nil, "BACKGROUND")
  aura.icon = icon
	icon:SetAllPoints(aura)
	
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
	if data.cd ~= nil then aura.cd = data.cd end
	if data.rppm ~= nil then aura.rppm = data.rppm end
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
	-- Set the change in the proper state and revert the change in that state's else
	-- Avail is only used on init, no event actually calls it again for the moment
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
		aura.icon:SetTexture(aura.iconPathAvail)
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
	else
	end
	
	-- optional changes:
	-- aura.icon:SetVertexColor(1,1,1,1)
	-- desaturate
	-- update icon
end


function DEO:PLAYER_ENTERING_WORLD()
  -- Need to check separate, later event since the MultiBarBottomLeft isn't shown until this point
  -- DEO:Print(ChatFrame4, "PLAYER_ENTERING_WORLD")
  --local SBFpoint, SBFrelativeTo, SBFrelativePoint, SBFxOffset, SBFyOffset = _G.StanceBarFrame:GetPoint() DEO:Print(ChatFrame4, SBFxOffset, SBFyOffset)
  --local PABFpoint, _, _, PABFxOffset, PABFyOffset = _G.PetActionBarFrame:GetPoint()
  local MBBL = _G.MultiBarBottomLeft:IsVisible()
  --if floor(SBFyOffset) == 45 then MBBL = false end DEO:Print(ChatFrame4, MBBL, SBFyOffset)
  --if SBFyOffset == 17 then MBBL = true end DEO:Print(ChatFrame4, MBBL, SBFyOffset)
  --if floor(PABFyOffset) == 0 or floor(PABFxOffset) == 500 then PABF = false end DEO:Print(ChatFrame4, PABF, floor(PABFyOffset))
  --if floor(PABFyOffset) >= 97 then PABF = true end DEO:Print(ChatFrame4, PABF, floor(PABFyOffset)) --142?
  local DEOyOffset, DEOxOffset = 38, -30
  if false == _G.MultiBarBottomLeft:IsVisible() then DEOyOffset = -5 end

	--DEOContainer = CreateFrame("FRAME", "DEOContainer", UIParent)
	DEOContainer:SetPoint("RIGHT",_G.MultiBarBottomRight,"LEFT",DEOxOffset,DEOyOffset)
  --_G.PetActionBarFrame:SetPoint(PABFpoint,PABFxOffset, PABFyOffset)  
end
function DEO:OnDisable()
    -- Called when the addon is disabled
end
DEO:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
DEO:RegisterEvent("PLAYER_ENTERING_WORLD")