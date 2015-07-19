-- Just copy/paste your code here now. It will execute every time the game loads.
-- http://www.arenajunkies.com/topic/222642-default-ui-scripts/

-- Class color UnitFrame names
--[[
local frame = CreateFrame("FRAME")
frame:RegisterEvent("GROUP_ROSTER_UPDATE")
frame:RegisterEvent("PLAYER_TARGET_CHANGED")
frame:RegisterEvent("PLAYER_FOCUS_CHANGED")
frame:RegisterEvent("UNIT_FACTION")

local function eventHandler(self, event, ...)
        if UnitIsPlayer("target") then
                c = RAID_CLASS_COLORS[select(2, UnitClass("target"))]
                TargetFrameNameBackground:SetVertexColor(c.r, c.g, c.b)
        end
        if UnitIsPlayer("focus") then
                c = RAID_CLASS_COLORS[select(2, UnitClass("focus"))]
                FocusFrameNameBackground:SetVertexColor(c.r, c.g, c.b)
        end
end

frame:SetScript("OnEvent", eventHandler)

for _, BarTextures in pairs({TargetFrameNameBackground, FocusFrameNameBackground}) do
        BarTextures:SetTexture("Interface\\TargetingFrame\\UI-StatusBar")
end
]]--

-- Hide button texts
local toggle = 0
	-- Hide macro text
	for i=1, 12 do
			_G["ActionButton"..i.."Name"]:SetAlpha(toggle) -- main bar
			_G["MultiBarBottomRightButton"..i.."Name"]:SetAlpha(toggle) -- bottom right bar
			_G["MultiBarBottomLeftButton"..i.."Name"]:SetAlpha(toggle) -- bottom left bar
			_G["MultiBarRightButton"..i.."Name"]:SetAlpha(toggle) -- right bar
			_G["MultiBarLeftButton"..i.."Name"]:SetAlpha(toggle) -- left bar
	end

	-- Hide keybind text
	for i=1, 12 do
			_G["ActionButton"..i.."HotKey"]:SetAlpha(toggle) -- main bar
			_G["MultiBarBottomRightButton"..i.."HotKey"]:SetAlpha(toggle) -- bottom right bar
			_G["MultiBarBottomLeftButton"..i.."HotKey"]:SetAlpha(toggle) -- bottom left bar
			_G["MultiBarRightButton"..i.."HotKey"]:SetAlpha(toggle) -- right bar
			_G["MultiBarLeftButton"..i.."HotKey"]:SetAlpha(toggle) -- left bar
	end
	for i=1, 10 do
			_G["PetActionButton"..i.."HotKey"]:SetAlpha(toggle) -- main bar
	end


-- Show CastBar timers 
--[[
CastingBarFrame.timer = CastingBarFrame:CreateFontString(nil);
CastingBarFrame.timer:SetFont(STANDARD_TEXT_FONT,12,"OUTLINE");
CastingBarFrame.timer:SetPoint("TOP", CastingBarFrame, "BOTTOM", 0, 0);
CastingBarFrame.update = .1;
hooksecurefunc("CastingBarFrame_OnUpdate", function(self, elapsed)
        if not self.timer then return end
        if self.update and self.update < elapsed then
                if self.casting then
                        self.timer:SetText(format("%2.1f/%1.1f", max(self.maxValue - self.value, 0), self.maxValue))
                elseif self.channeling then
                        self.timer:SetText(format("%.1f", max(self.value, 0)))
                else
                        self.timer:SetText("")
                end
                self.update = .1
        else
                self.update = self.update - elapsed
        end
end)
]]--

-- Slash commands
SlashCmdList["CLCE"] = function() CombatLogClearEntries() end
SLASH_CLCE1 = "/clc"

SlashCmdList["TICKET"] = function() ToggleHelpFrame() end
SLASH_TICKET1 = "/gm"

SlashCmdList["READYCHECK"] = function() DoReadyCheck() end
SLASH_READYCHECK1 = '/rc'

SlashCmdList["CHECKROLE"] = function() InitiateRolePoll() end
SLASH_CHECKROLE1 = '/cr'

SlashCmdList["GETPOINT"] = function(frame) local a,b,c,d,e =  _G[frame]:GetPoint(); local f = b:GetName(); local g =_G[frame]:IsVisible(); print(frame,a,d,e,f,c,g) end
SLASH_GETPOINT1 = '/getpoint'
