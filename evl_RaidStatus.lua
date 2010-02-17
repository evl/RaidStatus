evl_RaidStatus = CreateFrame("Button", nil, UIParent)
evl_RaidStatus:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 3, -3)
evl_RaidStatus:SetHeight(16)

local text = evl_RaidStatus:CreateFontString(nil, "ARTWORK")
text:SetFontObject(GameFontHighlightSmall)
text:SetPoint("TOPLEFT", evl_RaidStatus)

local MemberSortCompare = function(a, b)
	return ((a.color.r + a.color.g + a.color.b) .. a.name) < ((b.color.r + b.color.g + b.color.b) .. b.name)
end

local watches = {}
function evl_RaidStatus:AddWatch(name, callback)
	watches[name] = callback
end

local lastUpdate = 0
local updateInterval = 1
local result, name, unit, callback, count
local onUpdate = function(self, elapsed)
	lastUpdate = lastUpdate + elapsed
	
	if lastUpdate > updateInterval then
		lastUpdate = 0
		result = {}

		for name, callback in pairs(watches) do
			count = 0
			
			for i = 1, MAX_RAID_MEMBERS do
				local unit = "raid" .. i

				if UnitExists(unit) and callback(unit) then
					count = count + 1
				end
			end
			
			if count > 0 then
				table.insert(result, name .. ": " .. count)
			end
		end
		
		text:SetText(#result > 0 and strjoin(", ", unpack(result)) or "")
		evl_RaidStatus:SetWidth(text:GetWidth())
	end
end

local matches, class, classId, match
local onEnter = function()
	GameTooltip:SetOwner(evl_RaidStatus, "ANCHOR_BOTTOMLEFT")
	
	for name, callback in pairs(watches) do
		matches = {}
		
		for i = 1, MAX_RAID_MEMBERS do
			local unit = "raid" .. i

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
			
			table.sort(matches, MemberSortCompare)
			
			for _, match in pairs(matches) do
				GameTooltip:AddLine(match.name, match.color.r, match.color.g, match.color.b)
			end
		end
	end
	
	GameTooltip:Show()
end

evl_RaidStatus:SetScript("OnUpdate", onUpdate)
evl_RaidStatus:SetScript("OnEnter", onEnter)
evl_RaidStatus:SetScript("OnLeave", function() GameTooltip:Hide() end)

evl_RaidStatus:AddWatch("Dead", function(unit) return UnitIsDeadOrGhost(unit) end)
evl_RaidStatus:AddWatch("Offline", function(unit) return not UnitIsConnected(unit) end)
evl_RaidStatus:AddWatch("AFK", function(unit) return UnitIsAFK(unit) end)
