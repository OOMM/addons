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

function DEO:PLAYER_ENTERING_WORLD()
  DEO:ContainerPosition()
end

function DEO:PLAYER_LOGIN()
end

function DEO:PLAYER_TALENT_UPDATE()
  DEO:Start()
end

function DEO:UNIT_AURA(_,unit)
  if unit == "player" then
    for key,val in pairs(DEOEnabled) do
      DEO:Refresh(key)
    end
  end
end

function DEO:UNIT_INVENTORY_CHANGED()
  DEO:ContainerUpdate()
end

DEO:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
DEO:RegisterEvent("PLAYER_ENTERING_WORLD")
DEO:RegisterEvent("PLAYER_LOGIN")
DEO:RegisterEvent("PLAYER_TALENT_UPDATE")
DEO:RegisterEvent("UNIT_AURA")
DEO:RegisterEvent("UNIT_INVENTORY_CHANGED")
