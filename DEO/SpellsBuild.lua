
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
    
    if state then 
      DEOEnabled[tracking.buff] = true 
      DEO:Print(ChatFrame4, "Enabled: ", tracking.buff)
    else
      DEOEnabled[tracking.buff] = false 
      DEO:Print(ChatFrame4, "Disabled: ", tracking.buff)
    end
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
    else
      enabler(tracking,false)
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
	 
	for key,val in pairs(DEOSpells) do
  
		-- Buff Name
		DEOSpells[key].buff = key
      
		-- Should this be enabled?
    DEO:TrackingSetEnable(DEOSpells[key],equipped)

    -- If it is enabled
		if DEOSpells[key].enabled then

			-- Item Slot
      if DEOSpells[key].slot == nil then
        DEOSpells[key].slot = equipped[DEOSpells[key].itemid] or 0
      end

			-- Base Icon
      DEO:TrackingSetIconPathAvail(DEOSpells[key],equipped)

			-- ID (Buff Name aZ)
			DEOSpells[key].id = "DEO".. key:gsub('%W','')
			
			-- RPPM into Cooldown
      DEO:TrackingRPPMtoCD(DEOSpells[key])
		else
      if _G[DEOSpells[key].id] ~= nil then 
        _G[DEOSpells[key].id]:Hide()
      end
    end
	end
end