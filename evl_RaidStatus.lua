evl_RaidStatus = CreateFrame("Button", nil, UIParent)

local text
local members = {}
local watches = {}

local MemberSortCompare = function(a, b)
	return ((a.color.r + a.color.g + a.color.b) .. a.name) < ((b.color.r + b.color.g + b.color.b) .. b.name)
end

function evl_RaidStatus:AddWatch(name, callback)
	watches[name] = callback
end

local unit, i
function evl_RaidStatus:onEvent()
	members = {}

	for i = 0, 25 do
		unit = "raid" .. i

		if UnitExists(unit) then
			_, _, group = GetRaidRosterInfo(i)
			
			if group <= 5 then
				table.insert(members, unit)
			end
		end
	end	
end

local lastUpdate = 0
local result, name, callback, count
function evl_RaidStatus:onUpdate(elapsed)
	lastUpdate = lastUpdate + elapsed
	
	if lastUpdate > 1 then
		lastUpdate = 0

		if #members > 0 then
			result = ""
			
			for name, callback in pairs(watches) do
				count = 0
				
				for _, unit in pairs(members) do
					if UnitExists(unit) and callback(unit) then
						count = count + 1
					end
				end
				
				if count > 0 then
					if string.len(result) > 0 then
						result = result .. ", "
					end
					
					result = result .. name .. ": " .. count
				end
			end
			
			text:SetText(result)
			self:SetWidth(text:GetWidth())
		else
			text:SetText("")
		end
	end
end

local matches, class, classId, match
function evl_RaidStatus:onEnter()
	if #members > 0 then
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
		
		for name, callback in pairs(watches) do
			matches = {}
			
			for _, unit in pairs(members) do
				if UnitExists(unit) and callback(unit) then
					class, classId = UnitClass(unit)
					table.insert(matches, {name = UnitName(unit), color = RAID_CLASS_COLORS[classId]})
				end
			end
			
			if next(matches) then
				if GameTooltip:NumLines() > 0 then
					GameTooltip:AddLine("\n")
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
end


function evl_RaidStatus:new()
	self:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 3, -3)
	self:SetHeight(16)
	
	self:SetScript("OnUpdate", self.onUpdate)
	self:SetScript("OnEnter", self.onEnter)
	self:SetScript("OnLeave", function() GameTooltip:Hide() end)
	self:SetScript("OnEvent", self.onEvent)
	self:RegisterEvent("RAID_ROSTER_UPDATE")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	
	text = self:CreateFontString(nil, "ARTWORK")
	text:SetFontObject(GameFontHighlightSmall)
	text:SetPoint("TOPLEFT", self)
end

evl_RaidStatus:new()

evl_RaidStatus:AddWatch("Dead", function(unit) return UnitIsDeadOrGhost(unit) end)
evl_RaidStatus:AddWatch("Offline", function(unit) return not UnitIsConnected(unit) end)
evl_RaidStatus:AddWatch("AFK", function(unit) return UnitIsAFK(unit) end)
