local addonName, addon = ...

addon:AddWatch("Members", "PARTY_MEMBERS_CHANGED", function(unit) return not IsInInstance() and UnitIsConnected(unit) end)
addon:AddWatch("Dead", "UPDATE", function(unit) return UnitIsDeadOrGhost(unit) end)
addon:AddWatch("Offline", {"PARTY_MEMBER_DISABLE", "PARTY_MEMBER_ENABLE"}, function(unit) return not UnitIsConnected(unit) end)
addon:AddWatch("AFK", "PLAYER_FLAGS_CHANGED", function(unit) return UnitIsAFK(unit) end)
