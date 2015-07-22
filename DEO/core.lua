DEO = LibStub("AceAddon-3.0"):NewAddon("DEO", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0")


function DEO:SetState(aura)
	-- Set the change in the proper state and revert the change in that state's else
	-- Avail is only used on init, no event actually calls it again for the moment
	local state = aura.state
  
	local function UpdateTime()
		aura.text:SetText(string.format("%.f",aura.expirationTime-GetTime()))
	end

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

	if state == "cd" then
		if aura.cd > 0 then aura.cooldown:Show() end
	else
		aura.cooldown:Hide()
	end

	if state == "avail" then 
	else
	end

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

function DEO:Start()

	DEO:Print(ChatFrame4, "Loaded.")
	DEO:GetSpec()
  DEO:SpellsLoad()
	DEO:TrackingBuild()
  
    DEO:CreateContainer()
	DEO:CreateAuras()
end
function DEO:ContainerUpdate()
	DEO:Print(ChatFrame4, "Updated Items.")
	DEO:TrackingBuild()
  
  --DEO:CreateContainer()
  --DEO:ContainerPosition()
	DEO:CreateAuras()
end

function DEO:OnInitialize() end
function DEO:OnDisable() end