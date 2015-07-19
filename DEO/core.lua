DEO = LibStub("AceAddon-3.0"):NewAddon("DEO", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0")
local function p(str)
	DEO:Print(ChatFrame4, str)
end

function DEO:TrackingList()
	-- Aura Properties
	DEOTracking = {}
	-- Enchant
	DEOTracking["Mark of Bleeding Hollow"] = { spid = 173322, rppm = 2.3, originType = "enchant", slot = 16}
	-- Equipment
	DEOTracking["Howling Soul"] = { spid = 177046, rppm = 0.92, originType = "equipment", itemid = 119194}
	DEOTracking["Archmage's Greater Incandescence"] = { spid = 177176, rppm = 0.92, originType = "equipment", itemid = 118306}
	DEOTracking["Instability"] = { spid = 177051, rppm = 0.92, originType = "equipment", itemid = 113948}
	DEOTracking["Nightmare Fire"] = { spid = 162919, cd = 115, originType = "equipment", itemid = 112320}
	-- Item
	--DEOTracking["Draenic Intellect Potion"] = { spid = 156426, originType = "item", itemid = 109218}
	-- Heroism - special case
	--DEOTracking["Heroism"] = { spid = {32182}, spidDebuff = 57723, originType = "heroism",}
	--p(DEOTracking["Heroism"]["spid"][1])
end
 
function DEO:GetEquipped()
	-- Getting equipped Ring and Trinket itemid
	local equipped = {}
	local itemid = 0
	for slot=11,14,1 do
		itemid = GetInventoryItemID("player", slot) or 0
		equipped[itemid] = true
	end
  return equipped
end

function DEO:TrackingSetEnable(tracking,equipped)
  -- Are we going to show an aura for this tracked element?
  if (tracking.originType ~= "equipment") then 
    tracking.enabled = true
  elseif (tracking.originType == "equipment") and (equipped[tracking.itemid] ~= nil) then
    tracking.enabled = true
  else
    tracking.enabled = false
  end
end

function DEO:TrackingSetIconPathAvail(tracking,equipped)
  tracking.iconPathAvail = "Interface\\Icons\\INV_Misc_QuestionMark"
  if tracking.originIcon ~= nil then
    tracking.iconPathAvail = "Interface\\Icons\\".. tracking.originIcon
  elseif (tracking.originType == "equipment") and (equipped[tracking.itemid] ~= nil) then
    tracking.iconPathAvail = GetItemIcon(tracking.itemid)
  elseif tracking.slot ~= nil then
    tracking.iconPathAvail = GetItemIcon(GetInventoryItemID("player", tracking.slot))
  else
    if GetSpellInfo(tracking.spid) then
      _, _, tracking.iconPathAvail = GetSpellInfo(tracking.spid)
    else 
      _, _, tracking.iconPathAvail = GetSpellInfo(tracking.spid[1])
    end
  end
end

function DEO:TrackingRPPMtoCD(tracking)
  if nil == tracking.cd and nil == tracking.spidDebuff and tracking.rppm ~= nio and tracking.rppm ~= 0 then
    tracking.cd = 60/tracking.rppm
    p(tracking.cd)
  end
end 
function DEO:TrackingBuild()
  -- Build IDs, IconPath, buff, rppm - make sure each of these is assigned within DEO:Create
  
  -- What is equipped?
  local equipped = DEO:GetEquipped()
	
	local position = 0
  
	for key,val in pairs(DEOTracking) do

		-- Should this be enabled?
    DEO:TrackingSetEnable(DEOTracking[key],equipped)
    
    -- If it is enabled
		if DEOTracking[key].enabled then
      
			DEOTracking[key].auraPosition = position
			position = position + 1
			
			-- Base Icon
      DEO:TrackingSetIconPathAvail(DEOTracking[key],equipped)
			
			-- Buff Name, might not be useful
			DEOTracking[key].buff = key
			
			-- ID (Buff Name aZ)
			DEOTracking[key].id = "DEO".. key:gsub('%W','')
			
			-- RPPM into Cooldown
      DEO:TrackingRPPMtoCD(DEOTracking[key])

		end
	end
end

function DEO:CreateContainer()
  -- Creating Container - Is repositioned on PLAYER_ENTERING_WORLD
	DEOContainer = CreateFrame("FRAME", "DEOContainer", UIParent)
	DEOContainer:SetPoint("RIGHT",_G.MultiBarBottomRight,"LEFT",0,300)
	DEOContainer:SetWidth(42*4)
	DEOContainer:SetHeight(66)
end

function DEO:CreateAuras()
	-- Creating Auras
	local parent = DEOContainer
	for key,val in pairs(DEOTracking) do
		if DEOTracking[key].enabled then
			_G[DEOTracking[key].id] = DEO:CreateAura(DEOTracking[key],parent)
			_G[DEOTracking[key].id]:SetScale(.8)
			DEO:SetState(_G[DEOTracking[key].id])
			DEO:Print(ChatFrame4, "Created: ", _G[DEOTracking[key].id].id)
		end
	end
end

function DEO:CreateAura(data, parent)
	-- DEOContainer > aura - Aura is the the item we are tracking
  local aura = CreateFrame("FRAME", data.id .. "Aura", parent)
	aura.auraPosition = data.auraPosition
	aura:SetPoint("RIGHT",-42*aura.auraPosition,1)
	aura:SetWidth(38)
	aura:SetHeight(38)
	
	-- DEOContainer > aura > icon - Icon of the spell
  local icon = aura:CreateTexture(nil, "BACKGROUND")
  aura.icon = icon
	icon:SetAllPoints(aura)
	
	-- DEOContainer > aura > buttonBorder - Border, actually on top of the Icon
	local buttonBorder = aura:CreateTexture(nil, "ARTWORK")
	aura.buttonBorder = buttonBorder
  buttonBorder:SetPoint("CENTER",0,-1)
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

function DEO:COMBAT_LOG_EVENT_UNFILTERED(...)
	local event, timeStamp, subevent, _, sguid, sname, _, _, dguid, dname, _, _, spid, spname = ...
	if dguid == UnitGUID("player") then
		local isSpellTracked = _G.DEOTracking[spname] ~= nil
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


function DEO:Start()
	DEO:Print(ChatFrame4, "Loaded.")
	DEO:TrackingList()
	DEO:TrackingBuild()
  
  DEO:CreateContainer()
	DEO:CreateAuras()
end

function DEO:PLAYER_LOGIN()
 DEO:Start()
end

function DEO:PLAYER_ENTERING_WORLD()
  -- Need to check separate, later event since the MultiBarBottomLeft isn't shown until this point
  local MBBL = _G.MultiBarBottomLeft:IsVisible()
  local DEOyOffset, DEOxOffset = 38, -30
  if false == _G.MultiBarBottomLeft:IsVisible() then DEOyOffset = -5 end
	DEOContainer:SetPoint("RIGHT",_G.MultiBarBottomRight,"LEFT",DEOxOffset,DEOyOffset)
end

function DEO:OnInitialize()

end

function DEO:OnDisable()
    -- Called when the addon is disabled
end

DEO:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
DEO:RegisterEvent("PLAYER_ENTERING_WORLD")
DEO:RegisterEvent("PLAYER_LOGIN")