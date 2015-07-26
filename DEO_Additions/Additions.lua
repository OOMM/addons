DEOA = LibStub("AceAddon-3.0"):NewAddon("DEOA", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0")
DEOADebug = false --print function messages to ChatFrame4

function DEOA:CreateContainer()

	if  nil == DEOAContainer  then
    if DEOADebug then DEOA:Print(ChatFrame4, "Creating Container") end
    DEOAContainer = CreateFrame("FRAME", "DEOAContainer", UIParent)
    DEOAContainer:SetPoint("CENTER",_G.PlayerFrameTexture,"TOPLEFT",73,-13)
    DEOAContainer:SetWidth(28)
    DEOAContainer:SetHeight(28)
    
    local icon = DEOAContainer:CreateTexture(nil, "BACKGROUND")
    DEOAContainer.icon = icon
    icon:SetAllPoints(DEOAContainer)
   end
end

function DEOA:Start()
  local iconNum = GetRaidTargetIndex("player")
  DEOA:CreateContainer()
  if iconNum then
    DEOAContainer.icon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_"..iconNum)
  else
    if DEOAContainer then DEOAContainer:Hide() end
  end
  DEOA:TargetFrame()
end

function DEOA:TargetFrame()
  PlayerFrameBackground:Hide()
end

DEOA:Start()
DEOA:RegisterEvent("RAID_TARGET_UPDATE","Start")