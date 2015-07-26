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
