
function DEO:CreateContainer()
  -- Creating Container - Is repositioned on PLAYER_ENTERING_WORLD
	if  nil == DEOContainer  then
    DEOContainer = CreateFrame("FRAME", "DEOContainer", UIParent)
    DEOContainer:SetPoint("RIGHT",_G.MultiBarBottomRight,"LEFT",0,300)
    DEOContainer:SetWidth(42*12)
    DEOContainer:SetHeight(66)
    DEO:Print(ChatFrame4, "|cffC03E6CCreated:|r","Container")
  else
    DEO:Print(ChatFrame4, "|cffF2C43BReused:|r","Container")
  end
end

function DEO:CreateAuras()
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
  for slot=17,-7,-1 do
    order[slot] = nil
  end
	for key,_ in pairs(DEOSpells) do
		if DEOSpells[key].enabled then
      order[DEOSpells[key].slot] = DEOSpells[key].buff 
      DEO:Print(ChatFrame4, "|cffA2EFDFOrdered:|r","|cffD3965DEnabled:|r",DEOSpells[key].slot,string.sub(DEOSpells[key].buff or "nil",0,4), string.sub(order[DEOSpells[key].slot] or "nil",0,4) )
		else 
      DEO:Print(ChatFrame4, "|cffA2EFDFOrdered:|r","|cff713B0FSkipped:|r",DEOSpells[key].slot,string.sub(DEOSpells[key].buff or "nil",0,4), string.sub(order[DEOSpells[key].slot] or "nil",0,4) )
    end
    
	end
	local parent = DEOContainer
  local tkey = 0
  local position = 0
	for slot=17,-7,-1 do
    tkey = order[slot]
    if tkey ~= nil then
      _G[DEOSpells[tkey].id] = DEO:CreateAura(DEOSpells[tkey],parent,position,slot)
      _G[DEOSpells[tkey].id]:SetScale(.8)
      DEO:SetState(_G[DEOSpells[tkey].id])
      position = position + 1
    else
        local frameId = "DEOAura"..slot
        if _G[frameId] ~= nil then
          _G[frameId]:Hide()
          DEO:Print(ChatFrame4, "|cff713B0FHid:|r", frameId)
        end
    end
	end
end

function DEO:CreateAura(data, parent, position,slot)
  local aura
  local frameId = "DEOAura"..slot
  
  if nil == _G[frameId] then 
    aura = CreateFrame("FRAME", frameId, parent)
    DEO:Print(ChatFrame4, "|cffC03E6CCreated:|r", frameId, data.id) 
    aura:SetPoint("RIGHT",-42*position,1)
    aura:SetWidth(38)
    aura:SetHeight(38)

    local icon = aura:CreateTexture(nil, "BACKGROUND")
    aura.icon = icon
    icon:SetAllPoints(aura)
    
    local buttonBorder = aura:CreateTexture(nil, "ARTWORK")
    aura.buttonBorder = buttonBorder
    buttonBorder:SetPoint("CENTER",0,-1)
    buttonBorder:SetWidth(66)
    buttonBorder:SetHeight(66)
    buttonBorder:SetTexture("Interface\\Buttons\\UI-Quickslot2");

    local cooldown = CreateFrame("COOLDOWN", nil, aura, "CooldownFrameTemplate")
    aura.cooldown = cooldown
    cooldown:SetAllPoints(icon)
    cooldown:SetDrawEdge(false)

    local textFrame = CreateFrame("frame", nil, aura)
    textFrame:SetFrameLevel(cooldown:GetFrameLevel() + 1)
    local text = textFrame:CreateFontString(nil, "OVERLAY")
    aura.text = text
    aura.text:SetFont("Fonts\\FRIZQT__.TTF",16,"OUTLINE")
    aura.text:SetAllPoints(icon)

    local stacksFrame = CreateFrame("frame", nil, aura)
    stacksFrame:SetFrameLevel(textFrame:GetFrameLevel() + 1)
    local stacks = stacksFrame:CreateFontString(nil, "OVERLAY")
    aura.stacks = stacks
    aura.stacks:SetFont("Fonts\\ARIALN.TTF",13,"OUTLINE")
    aura.stacks:SetPoint("BOTTOMLEFT",icon,"BOTTOMLEFT",3,3)
    aura.stacks:SetHeight(15)
    aura.stacks:SetHeight(15)
  else
    aura = _G[frameId]
    DEO:Print(ChatFrame4, "|cffF2C43BReused:|r", frameId, data.id)
  end
  
  aura.icon:SetTexture(aura.iconPathUp)
  aura:Show()
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