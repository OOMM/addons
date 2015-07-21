DEO = LibStub("AceAddon-3.0"):NewAddon("DEO", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0")
local function p(str)
	DEO:Print(ChatFrame4, str)
end

function DEO:TrackingList()
	-- Aura Properties
	DEOTracking = {}
	-- Enchant
  local originType = "enchant"
    DEOTracking["Mark of Bleeding Hollow"] = { spid = 173322, rppm = 2.3, slot = 16, originType = originType }
	-- Equipment
  originType = "equipment"
    DEOTracking["Howling Soul"] = { spid = 177046, itemid = 119194, rppm = 0.92, originType = originType }
    DEOTracking["Archmage's Greater Incandescence"] = { spid = 177176, itemid = 118306, rppm = 0.92, originType = originType }
    DEOTracking["Instability"] = { spid = 177051, itemid = 113948, rppm = 0.92, originType = originType }
    DEOTracking["Nightmare Fire"] = { spid = 162919, itemid = 112320, cd = 115, originType = originType }
	-- Tier
  originType = "tier"
    -- two piece
      local slot = -2
        DEOTracking["Demon Rush"] = { spid = 188857, itemid = {124156,124167,124173,124179,124162}, numitems = 2, slot = slot, originIcon = "ability_rogue_deadlymomentum", originType = originType}
    -- four piece
      -- slot = -1
  -- Item
  --originType = "potion"
    --DEOTracking["Draenic Intellect Potion"] = { spid = 156426, itemid = 109218, originType = originType }
	-- Heroism - special case
  --originType = "heroism"
    --DEOTracking["Heroism"] = { spid = {32182}, spidDebuff = 57723, originType = originType }
end
 
function DEO:GetEquipped()
	-- Getting equipped Tier slot, Weapon, Ring and Trinket itemid
	local equipped = {}
  local slots = {1,3,5,10,7,11,12,13,14,16,17}
	local itemid = 0
	for _,slot in pairs(slots) do  
		itemid = GetInventoryItemID("player", slot) or 0
		equipped[itemid] = slot
	end
  return equipped
end

function DEO:TrackingSetEnable(tracking,equipped)
  -- Are we going to show an aura for this tracked element?
  if DEOEnabled == nil then DEOEnabled = {} end
  local function enabler(tracking, state)
    tracking.enabled = state
    
    if state then DEOEnabled[tracking.buff] = true end
  end
  
  if (tracking.originType == "equipment") and (equipped[tracking.itemid] ~= nil) then
    enabler(tracking,true)
  elseif (tracking.originType == "tier") then
    local i, numSetItemsEquipped = 0, 0
    for i=1,5,1 do
      if equipped[tracking.itemid[i]] ~= nil then
        numSetItemsEquipped = numSetItemsEquipped + 1
      end
    end
    if numSetItemsEquipped >= tracking.numitems then
      enabler(tracking,true)
    end
  elseif (tracking.originType == "enchant" or tracking.originType == "potion" or tracking.originType == "heroism") then 
    enabler(tracking,true)
  else
    enabler(tracking,false)
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
  if nil == tracking.cd and nil == tracking.spidDebuff and tracking.rppm ~= nil and tracking.rppm ~= 0 then
    tracking.cd = 60/tracking.rppm
  end
end

function DEO:TrackingBuild()
  -- Build IDs, IconPath, buff, rppm - make sure each of these is assigned within DEO:Create
  
  -- What is equipped?
  local equipped = DEO:GetEquipped()
	 
	for key,val in pairs(DEOTracking) do
  
		-- Buff Name
		DEOTracking[key].buff = key
      
		-- Should this be enabled?
    DEO:TrackingSetEnable(DEOTracking[key],equipped)

    -- If it is enabled
		if DEOTracking[key].enabled then

			-- Item Slot
      if DEOTracking[key].slot == nil then
        DEOTracking[key].slot = equipped[DEOTracking[key].itemid] or 0
      end

			-- Base Icon
      DEO:TrackingSetIconPathAvail(DEOTracking[key],equipped)


			
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
	DEOContainer:SetWidth(42*12)
	DEOContainer:SetHeight(66)
end

function DEO:CreateAuras()
	-- Creating Auras

  -- Order from right to left based on slot,
  -- non equipment will be given a custom negative slot id
  --  enchant
  --   17 - offhand
  --   16 - mainhand
  --  equipment
  --   14 - trinket1
  --   13 - trinket0
  --   12 - ring1
  --   11 - ring0
  --  tier
  --   -1 - tier four piece
  --   -2 - tier two piece
  --  item
  --   -6 - potion
  --  external
  --   -7 - heroism
  
  local order = {}
	for key,val in pairs(DEOTracking) do
		if DEOTracking[key].enabled then
      order[DEOTracking[key].slot] = DEOTracking[key].buff
		end
	end
	local parent = DEOContainer
  local tkey = 0
  local position = 0
	for k=17,-7,-1 do
    tkey = order[k]
    if tkey ~= nil then
      DEOTracking[tkey].auraPosition = position
      position = position + 1
      _G[DEOTracking[tkey].id] = DEO:CreateAura(DEOTracking[tkey],parent)
      _G[DEOTracking[tkey].id]:SetScale(.8)
      DEO:SetState(_G[DEOTracking[tkey].id])
      DEO:Print(ChatFrame4, "Created: ", _G[DEOTracking[tkey].id].slot, _G[DEOTracking[tkey].id].id)
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
	aura.text:SetFont("Fonts\\FRIZQT__.TTF",16,"OUTLINE")
	aura.text:SetAllPoints(icon)

	-- DEOContainer > aura > cooldown > stacksFrame > stacks - Stacks for stacking buffs
  local stacksFrame = CreateFrame("frame", nil, aura)
  stacksFrame:SetFrameLevel(textFrame:GetFrameLevel() + 1)
  local stacks = stacksFrame:CreateFontString(nil, "OVERLAY")
  aura.stacks = stacks
	aura.stacks:SetFont("Fonts\\ARIALN.TTF",13,"OUTLINE")
  aura.stacks:SetPoint("BOTTOMLEFT",icon,"BOTTOMLEFT",3,3)
  aura.stacks:SetHeight(15)
  aura.stacks:SetHeight(15)
	
	aura.id = data.id
	aura.slot = data.slot
	aura.buff = data.buff
	aura.iconPathUp = ""
	aura.iconPathAvail = data.iconPathAvail
	aura.cd = data.cd or 0
	aura.count = 0
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
		if aura.cd > 0 then aura.cooldown:SetCooldown(aura.expirationTime - aura.duration, aura.cd) end
		aura:SetScript("OnUpdate", UpdateTime)
    if aura.count > 0 then aura.stacks:SetText(string.format("%.f",aura.count)) end
	else
		aura.icon:SetTexture(aura.iconPathAvail)
		LibStub("LibButtonGlow-1.0").HideOverlayGlow(aura)
		aura:SetScript("OnUpdate", nil)
		aura.text:SetText("")
		aura.stacks:SetText("")
	end
	-------------
	-- STATE: cd
	-------------
	if state == "cd" then
		if aura.cd > 0 then aura.cooldown:Show() end
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
function DEO:Refresh(spname)
    local auraName = "DEO"..spname:gsub('%W','')
    local _, _, icon, count, _, duration, expirationTime = UnitAura("player",spname)
    if duration then
      _G[auraName].state = "up"
   -- _G["DEO"..spname:gsub('%W','')].timeStamp = timeStamp
      _G[auraName].iconPathUp =  icon
      if count > 0 then _G[auraName].count =  count  end        
      _G[auraName].duration = duration
      _G[auraName].expirationTime = expirationTime
      DEO:SetState(_G[auraName])
    end
end
function DEO:COMBAT_LOG_EVENT_UNFILTERED(...)
	local event, timeStamp, subevent, _, sguid, sname, _, _, dguid, dname, _, _, spid, spname = ...
	if dguid == UnitGUID("player") then
		local isSpellTracked = DEOEnabled[spname] or nil
    if subevent == "SPELL_AURA_APPLIED" or subevent == "SPELL_AURA_REFRESH" or subevent == "SPELL_AURA_APPLIED_DOSE" then
      if isSpellTracked then
        DEO:Refresh(spname)
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
	
function DEO:UNIT_AURA(...)
  local a,unit = ...

  if unit == "player" then
    for key,val in pairs(DEOEnabled) do
      DEO:Refresh(key)
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

DEO:RegisterEvent("UNIT_AURA")
DEO:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
DEO:RegisterEvent("PLAYER_ENTERING_WORLD")
DEO:RegisterEvent("PLAYER_LOGIN")