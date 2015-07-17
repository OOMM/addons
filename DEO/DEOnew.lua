--live up date cd text, icon line 333
DEO = LibStub("AceAddon-3.0"):NewAddon("DEO", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0")

function DEO:OnInitialize()
	DEOTracking = {
	MarkofBleedingHollow = true
	}
	
	data = {
	id = "DEO:MarkofBleedingHollow",
	buffName = "Mark of Bleeding Hollow",
	iconName = "spell_shadow_demonictactics",
	cd = 26
	}

  DEO:Print(ChatFrame4, "Loaded.")
  tracking = _G["DEOTracking"][data.buffName:gsub('%W','')] ~= nil
  
  local parent = UIParent
  _G[data.id] = DEO:Create(data,parent)
  DEO:SetState(data.id,"avail")
	_G[data.id]:SetScale(UIParent:GetEffectiveScale())
end
function DEO:Create(data, parent)
    local font = "GameFontHighlight";

    local region = CreateFrame("FRAME", nil, parent);
    region:SetMovable(true);
    region:SetResizable(true);
    region:SetMinResize(1, 1);
	region:SetPoint("CENTER",0,0)
	--region:SetPoint("CENTER",-66,-525)
	region:SetWidth(36)
	region:SetHeight(36)
	
    local icon = region:CreateTexture(nil, "BACKGROUND");
    icon:SetAllPoints(region);
    region.icon = icon;
    icon:SetTexture("Interface\\Icons\\" .. data.iconName);

    --This section creates a unique frame id for the cooldown frame so that it can be created with a global reference
    --The reason is so that WeakAuras cooldown frames can interact properly with OmniCC (i.e., put on its blacklist for timer overlays)
    local id = data.id;
    local frameId = id:lower():gsub(" ", "_");
    if(_G[frameId]) then
        local baseFrameId = frameId;
        local num = 2;
        while(_G[frameId]) do
            frameId = baseFrameId..num;
            num = num + 1;
        end
    end
    region.frameId = frameId;

    local cooldown = CreateFrame("COOLDOWN", "DEOCooldown"..frameId, region, "CooldownFrameTemplate");
    region.cooldown = cooldown;
    cooldown:SetAllPoints(icon);
    cooldown:SetDrawEdge(false);

    local stacksFrame = CreateFrame("frame", nil, region);
    stacksFrame:SetFrameLevel(cooldown:GetFrameLevel() + 1);
    local stacks = stacksFrame:CreateFontString(nil, "OVERLAY");
    region.stacks = stacks;
	region.stacks:SetFont("Fonts\\FRIZQT__.TTF",14,"OUTLINE");
	region.stacks:SetAllPoints(icon);
	
	local button = region:CreateTexture(nil, "ARTWORK")
	button:SetPoint("CENTER",0,0);
	region.button = button
	button:SetWidth(66);
	button:SetHeight(66);
	button:SetTexture("Interface\\Buttons\\UI-Quickslot2");	

    region.values = {};
    region.duration = 0;
    region.expirationTime = math.huge;
	return region
end
function DEO:OnDisable()
    -- Called when the addon is disabled
end

function DEO:COMBAT_LOG_EVENT_UNFILTERED(...)
	--DEO:Print(ChatFrame4, data.buffName)
	event, timeStamp, subevent, _, sguid, sname, _, _, dguid, dname, _, _, spid, spname = ...
	--DEO:Print(ChatFrame4, timeStamp, subevent, spid, spname)
	if dguid == UnitGUID("player") then
        if subevent == "SPELL_AURA_APPLIED" or subevent == "SPELL_AURA_REFRESH" then
            if spname == data.buffName then
                local spname, _, icon, count, _, duration, expires, _, _, _, spid = UnitAura("player",data.buffName)
				--_G["WAsao_"..data.buffName:gsub('%W','').."_icon"] =  icon;
				_G["WAsao_"..data.buffName:gsub('%W','').."_time"] = timeStamp;
				--print("trigger",data.buffName,_G["WAsao_"..buffName:gsub('%W','').."_time"]);
				_G["WAsao_"..data.buffName:gsub('%W','').."_duration"] = duration;
				_G["WAsao_"..data.buffName:gsub('%W','').."_expires"] = expires;
				--_G[data.id].icon:SetTexture(icon);
				DEO:SetState(data.id,"up");
			end
		end
		if subevent == "SPELL_AURA_REMOVED" then
			if spname == data.buffName then
				DEO:SetState(data.id,"cd");
			end
		end			
	end	
	
end	
function DEO:SetState(frame,state)
	-- state: avail, up, cd
	frame = _G[frame]
	local function UpdateTime()
		local expirationTime, duration = _G["WAsao_"..data.buffName:gsub('%W','').."_expires"], _G["WAsao_"..data.buffName:gsub('%W','').."_duration"];
		frame.stacks:SetText(string.format("%.f",expirationTime-GetTime()));
	end
	-------------
	-- UP
	-------------	
	if state == "up" then
		LibStub("LibButtonGlow-1.0").ShowOverlayGlow(frame);
		local expirationTime, duration = _G["WAsao_"..data.buffName:gsub('%W','').."_expires"], _G["WAsao_"..data.buffName:gsub('%W','').."_duration"];
		--frame.cooldown:SetCooldown(expirationTime, frame.cd);
		frame.cooldown:SetCooldown(expirationTime-duration, data.cd);
		frame:SetScript("OnUpdate", UpdateTime);
	else
		LibStub("LibButtonGlow-1.0").HideOverlayGlow(frame);
		frame:SetScript("OnUpdate", nil);
		frame.stacks:SetText("");
	end
	-------------
	-- COOLDOWN
	-------------
	if state == "cd" then
		--frame.icon:SetVertexColor(.8,.8,.8,.8);
		frame.cooldown:Show();	
	else
		frame.icon:SetVertexColor(1,1,1,1);
		frame.cooldown:Hide();
	end
	-------------
	-- AVAIL
	-------------	
	if state == "avail" then
		frame.icon:SetTexture("Interface\\Icons\\" .. data.iconName);
	else
	end
end
	
	
	
	
	
	
	
DEO:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
---
WAsaoText = function(buffName, defaultIcon, buffCooldown, isRPPM)
    if defaultIcon == 0 then defaultIcon = 'INV_staff_30' end
    defaultIconPath = "Interface\\Icons\\"..defaultIcon
    local iconPath = _G["WAsao_"..buffName:gsub('%W','').."_icon"] or defaultIconPath
    local eventTime = _G["WAsao_"..buffName:gsub('%W','').."_time"] or 0
    local buffDuration = _G["WAsao_"..buffName:gsub('%W','').."_duration"] or 0
    local buffExpires = _G["WAsao_"..buffName:gsub('%W','').."_expires"] or 0
    local text, textcolor, id, WA = '', '|cffEEFFEE', "sao: "..buffName, WeakAuras
    if isRPPM then
        buffCooldown = 60/buffCooldown
		_G["WAsao_"..buffName:gsub('%W','').."_cooldown"] = buffCooldown
    end
    
    if WA.regionTypes and WA.regionTypes.icon and WA.regionTypes.icon.modify then
        modify = WA.regionTypes.icon.modify
    end
    if WA.regions and WA.regions[id] and WA.regions[id]["region"] then
        reg = WA.regions[id]["region"]
    end
    local anchor, data = select(2,reg:GetPoint()), WA.GetData(id)
   
	
    data.desaturate = nil
    data.displayIcon = defaultIconPath
    data.color[1] = 1
    data.color[2] = 1
    data.color[3] = 1
    data.color[4] = 1
	--data.cooldown = false
	--reg.duration = buffExpires - GetTime()
	--reg.expirationTime = buffExpires
	data.trigger.duration = ""
	data.untrigger.custom = "function () return false end"
	data.trigger.customDuration = "function() local eventTime, cooldown = _G['WAsao_"..buffName:gsub('%W','').."_time'] or 0, _G['WAsao_"..buffName:gsub('%W','').."_cooldown'] or 0 if (eventTime+cooldown) > time() then local expires = eventTime+cooldown-time() return cooldown,GetTime()+expires end return 0,1 end"
	
	--data.trigger.customDuration = buffExpires - GetTime()
	

    if buffExpires > GetTime() then  
        text =  string.format("%.f",buffExpires - GetTime())
        data.displayIcon = iconPath
        data.color[1] = 1
        data.color[2] = 1
        data.color[3] = 1
        data.color[4] = 1
        --data.cooldown = false

    elseif -1*(buffExpires - GetTime()) < (buffCooldown-buffDuration) then
        text =  string.format("%.f",buffCooldown-buffDuration+(buffExpires - GetTime()))
        data.desaturate = nil
        data.displayIcon = iconPath
        data.color[1] = .8
        data.color[2] = .8
        data.color[3] = .8
        data.color[4] = 1
        textcolor = "|cffFF0011"
        --data.cooldown = true	
	--reg.duration = buffExpires - GetTime()
	--reg.expirationTime = buffExpires
	--data.trigger.duration = buffExpires - GetTime()
	--data.trigger.customDuration = buffExpires - GetTime()		

    end    
    modify(anchor, reg, data)
    
    return textcolor..text.."|r"
end
WAsaoTrigger = function(buffName,event,t,subevent,dguid,spname)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        if dguid == UnitGUID("player") then
            if subevent == "SPELL_AURA_APPLIED" or subevent == "SPELL_AURA_REFRESH" then
                if spname == buffName then
                    local spname, _, icon, count, _, duration, expires, _, _, _, spid = UnitAura("player",buffName)
                    --_G["WAsao_"..buffName:gsub('%W','').."_icon"] =  icon
                    _G["WAsao_"..buffName:gsub('%W','').."_time"] = t
					print("trigger",buffName,_G["WAsao_"..buffName:gsub('%W','').."_time"])
                    _G["WAsao_"..buffName:gsub('%W','').."_duration"] = duration
                    _G["WAsao_"..buffName:gsub('%W','').."_expires"] = expires
                    --print(duration, expires, GetTime(), t, time())
					WAsaoActions(buffName,true)	
                end
            end
			if subevent == "SPELL_AURA_REMOVED" then
				if spname == buffName then
					WAsaoActions(buffName,false)					
				end
			end			
        end
    end
end
WAsaoActions = function(buffName, isUp)
	local id = "sao: "..buffName
	local frame, WA = "WeakAuras:"..id, WeakAuras	
    local buffDuration = _G["WAsao_"..buffName:gsub('%W','').."_duration"] or 0
    local buffExpires = _G["WAsao_"..buffName:gsub('%W','').."_expires"] or 0
    local eventTime = _G["WAsao_"..buffName:gsub('%W','').."_time"] or 0

    local glow_frame;
    if WA.regionTypes and WA.regionTypes.icon and WA.regionTypes.icon.modify then
        modify = WA.regionTypes.icon.modify
    end
    if WA.regions and WA.regions[id] and WA.regions[id]["region"] then
        reg = WA.regions[id]["region"]
    end
    local anchor, data = select(2,reg:GetPoint()), WA.GetData(id)	
	if(frame:sub(1, 10) == "WeakAuras:") then
	  local frame_name = frame:sub(11);
	  if(WA.regions[frame_name]) then	  
		glow_frame = WA.regions[frame_name].region;
	  end
	else
		glow_frame = _G[frame];
	end
	if isUp then
		LibStub("LibButtonGlow-1.0").ShowOverlayGlow(glow_frame)
		data.cooldown = false
		--reg.duration = buffExpires - GetTime()
		--reg.expirationTime = buffExpires
		--data.trigger.duration = buffExpires - GetTime()
					
	else
		LibStub("LibButtonGlow-1.0").HideOverlayGlow(glow_frame)
		data.cooldown = true
	end
	modify(anchor, reg, data)
end
