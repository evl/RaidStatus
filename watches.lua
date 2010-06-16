local addonName, addon = ...

addon:AddWatch("Dead", function(unit) return UnitIsDeadOrGhost(unit) end)
addon:AddWatch("Offline", function(unit) return not UnitIsConnected(unit) end)
addon:AddWatch("AFK", function(unit) return UnitIsAFK(unit) end)
