
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
	for key,val in pairs(DEOSpells) do
		if DEOSpells[key].enabled then
      order[DEOSpells[key].slot] = DEOSpells[key].buff
		end
	end
	local parent = DEOContainer
  local tkey = 0
  local position = 0
	for k=17,-7,-1 do
    tkey = order[k]
    if tkey ~= nil then
      DEOSpells[tkey].auraPosition = position
      position = position + 1
      _G[DEOSpells[tkey].id] = DEO:CreateAura(DEOSpells[tkey],parent)
      _G[DEOSpells[tkey].id]:SetScale(.8)
      DEO:SetState(_G[DEOSpells[tkey].id])
      DEO:Print(ChatFrame4, "Created: ", _G[DEOSpells[tkey].id].slot, _G[DEOSpells[tkey].id].id)
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

function DEO:ContainerPosition()
  local MBBL = _G.MultiBarBottomLeft:IsVisible()
  local DEOyOffset, DEOxOffset = 38, -30
  if false == _G.MultiBarBottomLeft:IsVisible() then DEOyOffset = -5 end
	DEOContainer:SetPoint("RIGHT",_G.MultiBarBottomRight,"LEFT",DEOxOffset,DEOyOffset)
end