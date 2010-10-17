local addonName, addon = ...

addon.config = {
	position = {"TOPLEFT", UIParent, "TOPLEFT", 3, -3},
	font = {STANDARD_TEXT_FONT, 10},
}

local config = addon.config
local frame = CreateFrame("Button", nil, UIParent)
local watches = {}

local display = frame:CreateFontString(nil, "OVERLAY")
display:SetPoint("TOPLEFT", frame)

local memberSortCompare = function(a, b)
	return ((a.color.r + a.color.g + a.color.b) .. a.name) < ((b.color.r + b.color.g + b.color.b) .. b.name)
end

local onEvent = function()
	frame:SetPoint(unpack(config.position))
	frame:SetHeight(config.font[2])

	display:SetShadowOffset(0.7, -0.7)
	display:SetFont(unpack(config.font))
end

local lastUpdate = 0
local onUpdate = function(self, elapsed)
	lastUpdate = lastUpdate + elapsed
	
	if lastUpdate > 1 then
		lastUpdate = 0
		result = nil
		
		if GetNumRaidMembers() > 0 then
			for name, callback in pairs(watches) do
				local count = 0
	
				for i = 1, GetNumRaidMembers() do
					local unit = "raid" .. i

					if UnitExists(unit) and callback(unit) then
						count = count + 1
					end
				end
	
				if count > 0 then
					result = (result and result .. ", " or "") .. name .. ": " .. count
				end
			end
		end
		
		if result then
			display:SetText(result)
			display:Show()
	
			frame:SetWidth(display:GetWidth())
		else
			display:Hide()
		end
	end
end

local onEnter = function()
	GameTooltip:SetOwner(frame, "ANCHOR_BOTTOMLEFT")
	
	for name, callback in pairs(watches) do
		local matches = {}
		
		for i = 1, GetNumRaidMembers() do
			local unit = "raid" .. i

			if UnitExists(unit) and callback(unit) then
				local _, classId = UnitClass(unit)
				
				-- TODO: Make sure classId is available at this time
				table.insert(matches, {name = UnitName(unit), color = RAID_CLASS_COLORS[classId]})
			end
		end
		
		if next(matches) then
			if GameTooltip:NumLines() > 0 then
				GameTooltip:AddLine(" ")
			end

			GameTooltip:AddLine(name .. ":", 1, 1, 1)
			
			table.sort(matches, memberSortCompare)
			
			for _, match in pairs(matches) do
				GameTooltip:AddLine(match.name, match.color.r, match.color.g, match.color.b)
			end
		end
	end
	
	GameTooltip:Show()
end

function addon:AddWatch(name, callback)
	watches[name] = callback
end

frame:SetScript("OnUpdate", onUpdate)
frame:SetScript("OnEvent", onEvent)
frame:SetScript("OnEnter", onEnter)
frame:SetScript("OnLeave", function() GameTooltip:Hide() end)

frame:RegisterEvent("PLAYER_ENTERING_WORLD")