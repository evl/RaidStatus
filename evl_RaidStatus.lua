local addonName, addon = ...
local frame = CreateFrame("Button", nil, UIParent)
local watches = {}

local text = frame:CreateFontString(nil, "ARTWORK")
text:SetFontObject(GameFontHighlightSmall)
text:SetPoint("TOPLEFT", frame)

local memberSortCompare = function(a, b)
	return ((a.color.r + a.color.g + a.color.b) .. a.name) < ((b.color.r + b.color.g + b.color.b) .. b.name)
end

local onEvent = function(self, event)
	local result

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
		
	if result then
		text:SetText(result)
		text:Show()
	
		frame:SetWidth(text:GetWidth())
	else
		text:Hide()
	end
end

local matches, match, class, classId
local onEnter = function()
	GameTooltip:SetOwner(frame, "ANCHOR_BOTTOMLEFT")
	
	for name, callback in pairs(watches) do
		matches = {}
		
		for i = 1, GetNumRaidMembers() do
			unit = "raid" .. i

			if UnitExists(unit) and callback(unit) then
				class, classId = UnitClass(unit)
				
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

function addon:AddWatch(name, event, callback)
	if typeof(event) == "table" then
		for _, event in pairs(event) do
			frame:RegisterEvent(event)
		end
	else
		frame:RegisterEvent(event)
	end
	
	watches[name] = callback	
end

frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 3, -3)
frame:SetHeight(16)

frame:SetScript("OnEvent", onEvent)
frame:SetScript("OnEnter", onEnter)
frame:SetScript("OnLeave", function() GameTooltip:Hide() end)
frame:RegisterEvent("PLAYER_ENTERING_WORLD")