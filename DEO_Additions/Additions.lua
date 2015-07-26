DEOA = LibStub("AceAddon-3.0"):NewAddon("DEOA", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0")
DEOADebug = false --print function messages to ChatFrame4

function DEOA:CreateContainer()

	if  nil == DEOAContainer  then
    if DEOADebug then DEOA:Print(ChatFrame4, "Creating Container") end
    DEOAContainer = CreateFrame("FRAME", "DEOAContainer", UIParent)

    local icon = DEOAContainer:CreateTexture(nil, "BACKGROUND")
    DEOAContainer.icon = icon
    icon:SetAllPoints(DEOAContainer)
   
    DEOAContainer:SetPoint("CENTER",_G.PlayerFrameTexture,"TOPLEFT",73,-13)
    DEOAContainer:SetWidth(28)
    DEOAContainer:SetHeight(28)
  else
    if DEOADebug then DEOA:Print(ChatFrame4, "Reusing Container") end
  end
end

function DEOA:Start()

  local iconNum = GetRaidTargetIndex("player")
   if DEOADebug then DEOA:Print(ChatFrame4, iconNum) end
  DEOA:CreateContainer()
  if iconNum ~= nil then
    DEOAContainer.icon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_"..iconNum)
    DEOAContainer:Show()
    if DEOADebug then DEOA:Print(ChatFrame4, DEOAContainer.icon:GetTexture()) end
  else
    if DEOAContainer then DEOAContainer:Hide() end
  end
  DEOA:UnitFrameAlter()
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
SetCVar("cameraDistanceMax",50)
CompactRaidFrameContainer:SetScale(0.5)
MinimapCluster:SetScale(0.8)
PlayerFrameGroupIndicator:Hide(); PlayerFrameGroupIndicator.Show = function() end;
hooksecurefunc("TargetFrame_CheckDead", function(...) DEOA:UnitFrameAlter() end);
hooksecurefunc("TargetFrame_Update", function(...) DEOA:UnitFrameAlter() end);
hooksecurefunc("TargetFrame_CheckFaction", function(...) DEOA:UnitFrameAlter() end);
hooksecurefunc("TargetFrame_CheckClassification", function(...) DEOA:UnitFrameAlter() end);
hooksecurefunc("TargetofTarget_Update", function(...) DEOA:UnitFrameAlter() end);
-- BossFrame hooks
hooksecurefunc("BossTargetFrame_OnLoad", function(...) DEOA:UnitFrameAlter() end);
--HIDE COLORS BEHIND NAME
hooksecurefunc("TargetFrame_CheckFaction", function(self)
    self.nameBackground:SetVertexColor(0, 0, 0, 0);
end)

-- CLASS COLOR HP BAR
local function colour(statusbar, unit)
        local _, class, c
        if UnitIsPlayer(unit) and UnitIsConnected(unit) and unit == statusbar.unit and UnitClass(unit) then
                _, class = UnitClass(unit)
                c = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class]
                statusbar:SetStatusBarColor(c.r, c.g, c.b)
                --PlayerFrameHealthBar:SetStatusBarColor(0,1,0)
        end
end

hooksecurefunc("UnitFrameHealthBar_Update", colour)
hooksecurefunc("HealthBar_OnValueChanged", function(self)
        colour(self, self.unit)
end)
DEOA:RegisterEvent("RAID_TARGET_UPDATE","Start")
DEOA:RegisterEvent("UPDATE_WORLD_STATES","Start")
