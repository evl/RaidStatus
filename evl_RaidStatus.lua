local addonName, addon = ...

local frame = CreateFrame("Button", nil, UIParent)
local text = frame:CreateFontString(nil, "ARTWORK")
text:SetFontObject(GameFontHighlightSmall)
text:SetPoint("TOPLEFT", frame)

local memberSortCompare = function(a, b)
	return ((a.color.r + a.color.g + a.color.b) .. a.name) < ((b.color.r + b.color.g + b.color.b) .. b.name)
end

local watches = {}
function addon:AddWatch(name, callback)
	watches[name] = callback
end

local lastUpdate = 0
local updateInterval = 1
local result, name, unit, callback, count
local onUpdate = function(self, elapsed)
	lastUpdate = lastUpdate + elapsed
	
	if lastUpdate > updateInterval and GetNumRaidMembers() > 0 then
		lastUpdate = 0
		result = nil

		for name, callback in pairs(watches) do
			count = 0
			
			for i = 1, GetNumRaidMembers() do
				unit = "raid" .. i

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

frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 3, -3)
frame:SetHeight(16)
frame:SetScript("OnUpdate", onUpdate)
frame:SetScript("OnEnter", onEnter)
frame:SetScript("OnLeave", function() GameTooltip:Hide() end)
