local DaybloomMod = RegisterMod("Daybloom", 1)
local game = Game()

DaybloomMod.COLLECTIBLE_DAYBLOOM = Isaac.GetItemIdByName("Daybloom")
DaybloomMod.COSTUME_DAYBLOOM = Isaac.GetCostumeIdByPath("gfx/characters/daybloom.anm2")

function DaybloomMod:onUpdate(player)
	if game:GetFrameCount() == 1 then
		DaybloomMod.HasDaybloom = false
		 -- Spawn in if necessary
	end

	 -- makes sure player has Daybloom and updates game
	if not DaybloomMod.HasDaybloom and player:HasCollectible(DaybloomMod.COLLECTIBLE_DAYBLOOM) then
		player:AddNullCostume(DaybloomMod.COSTUME_DAYBLOOM)
		DaybloomMod.HasDaybloom = true
	end
end

DaybloomMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, DaybloomMod.onUpdate)