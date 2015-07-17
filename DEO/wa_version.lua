
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
