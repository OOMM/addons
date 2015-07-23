function DEO:GetEquipped()
	local equipped = {}
  local slots = {1,3,5,10,7,11,12,13,14,16,17}
	local itemid = 0
  
	for _,slot in pairs(slots) do  
		itemid = GetInventoryItemID("player", slot) or 0
		equipped[itemid] = slot
	end
  
  return equipped
end

function DEO:GetSpec()
	_, DEOPlayerClass = UnitClass("player")
	DEOPlayerSpec = GetSpecialization() --nil if under level 10
  if DEODebug then DEO:Print(ChatFrame4,"Player Class:",DEOPlayerClass, "Spec:", DEOPlayerSpec) end
end

function DEO:SpellsSetEnable(spell,equipped)
  if DEOEnabled == nil then DEOEnabled = {} end
  
  local function enabler(spell, state)
    spell.enabled = state
    
    if state then 
      DEOEnabled[spell.buff] = true 
      if DEODebug then DEO:Print(ChatFrame4, "|cffD3965DEnabled:|r", spell.buff) end
    else
      DEOEnabled[spell.buff] = false 
      if DEODebug then DEO:Print(ChatFrame4, "|cff713B0FDisabled:|r", spell.buff) end
    end
  end
  
  if (spell.originType == "equipment") and (equipped[spell.itemid] ~= nil) then
    enabler(spell,true)
  elseif (spell.originType == "tier") then
    local i, numSetItemsEquipped = 0, 0
    for i=1,5,1 do
      if equipped[spell.itemid[i]] ~= nil then
        numSetItemsEquipped = numSetItemsEquipped + 1
      end
    end
    if numSetItemsEquipped >= spell.numitems then
      enabler(spell,true)
    else
      enabler(spell,false)
    end
  elseif (spell.originType == "enchant" or spell.originType == "potion" or spell.originType == "heroism") then 
    enabler(spell,true)
  else
    enabler(spell,false)
  end
end

function DEO:SpellsSetIconPathAvail(spell,equipped)
  spell.iconPathAvail = "Interface\\Icons\\INV_Misc_QuestionMark"
  if spell.originIcon ~= nil then
    spell.iconPathAvail = "Interface\\Icons\\".. spell.originIcon
  elseif (spell.originType == "equipment") and (equipped[spell.itemid] ~= nil) then
    spell.iconPathAvail = GetItemIcon(spell.itemid)
  elseif spell.slot ~= nil then
    spell.iconPathAvail = GetItemIcon(GetInventoryItemID("player", spell.slot))
  else
    if GetSpellInfo(spell.spid) then
      _, _, spell.iconPathAvail = GetSpellInfo(spell.spid)
    else 
      _, _, spell.iconPathAvail = GetSpellInfo(spell.spid[1])
    end
  end
end

function DEO:SpellsRPPMtoCD(spell)
  if nil == spell.cd and nil == spell.spidDebuff and spell.rppm ~= nil and spell.rppm ~= 0 then
    spell.cd = 60/spell.rppm
  end
end

function DEO:SpellsBuild()
  
  local equipped = DEO:GetEquipped()
	 
	for key,_ in pairs(DEOSpells) do
  
		DEOSpells[key].buff = key
      
    DEO:SpellsSetEnable(DEOSpells[key],equipped)

		if DEOSpells[key].enabled then

      if DEOSpells[key].originType == "equipment" then
        DEOSpells[key].slot = equipped[DEOSpells[key].itemid] or 0
        if DEODebug then DEO:Print(ChatFrame4,"|cffCBE5DASlot Set:|r",DEOSpells[key].buff, equipped[DEOSpells[key].itemid] or 0) end
      end

      DEO:SpellsSetIconPathAvail(DEOSpells[key],equipped)

			DEOSpells[key].id = "DEO".. key:gsub('%W','')
			
      DEO:SpellsRPPMtoCD(DEOSpells[key])
		else
      if _G[DEOSpells[key].id] ~= nil then 
        _G[DEOSpells[key].id]:Hide()
      end
    end
	end
end