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
SetCVar("cameraDistanceMax",50)
  local iconNum = GetRaidTargetIndex("player")
  DEOA:CreateContainer()
  if iconNum then
    DEOAContainer.icon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_"..iconNum)
  else
    if DEOAContainer then DEOAContainer:Hide() end
  end

  hooksecurefunc("TargetFrame_CheckDead", function(...) DEOA:UnitFrameAlter() end);
	hooksecurefunc("TargetFrame_Update", function(...) DEOA:UnitFrameAlter() end);
	hooksecurefunc("TargetFrame_CheckFaction", function(...) DEOA:UnitFrameAlter() end);
	hooksecurefunc("TargetFrame_CheckClassification", function(...) DEOA:UnitFrameAlter() end);
	hooksecurefunc("TargetofTarget_Update", function(...) DEOA:UnitFrameAlter() end);
	-- BossFrame hooks
	hooksecurefunc("BossTargetFrame_OnLoad", function(...) DEOA:UnitFrameAlter() end);
end





  
  
function DEOA:UnitFrameAlter()
  c = RAID_CLASS_COLORS[select(2, UnitClass("player"))]
  PlayerFrameHealthBar:SetStatusBarColor(c.r, c.g, c.b)
  PlayerFrameBackground:Hide()

  if UnitExists("target") then
        TargetFrameNameBackground:Hide()
        if ( not UnitPlayerControlled("target") and UnitIsTapped("target") and not UnitIsTappedByPlayer("target") and not UnitIsTappedByAllThreatList("target") ) then
          TargetFrameHealthBar:SetStatusBarColor(0.5, 0.5, 0.5);
        else
          c = RAID_CLASS_COLORS[select(2, UnitClass("target"))]
          TargetFrameHealthBar:SetStatusBarColor(c.r, c.g, c.b)
        end        
  end
  if UnitExists("focus") then
          c = RAID_CLASS_COLORS[select(2, UnitClass("focus"))]
          FocusFrameHealthBar:SetStatusBarColor(c.r, c.g, c.b)
          FocusFrameNameBackground:Hide()
  end

end
DEOA:Start()
DEOA:RegisterEvent("RAID_TARGET_UPDATE","Start")
