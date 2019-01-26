local GreenCandle = RegisterMod("GreenCandle", 1)

GreenCandle.COLLECTIBLE_GREEN_CANDLE = Isaac.GetItemIdByName("Green Candle")

function GreenCandle:onUpdate()
	-- Beginning of run initialization
	if Game():GetFrameCount() == 1 then
		GreenCandle.HasGreenCandle = false
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, GreenCandle.COLLECTIBLE_GREEN_CANDLE, Vector(320, 300), Vector(0,0), nil)
	end

	-- Green Candle functionality
	for playerNum = 1, Game():GetNumPlayers() do
		local player = Game():GetPlayer(playerNum)
		if player:HasCollectible(GreenCandle.COLLECTIBLE_GREEN_CANDLE) then

			-- Gives a full Spirit Heart upon initial pickup
			if not GreenCandle.HasGreenCandle then
				player:AddSoulHearts(2)
				GreenCandle.HasGreenCandle = true
				Isaac.DebugString("Green Candle Obtained!")
			end

			-- Randomly poisons enemies
			for i, entity in pairs(Isaac.GetRoomEntities()) do
				if entity:IsVulnerableEnemy() and math.random(500) == 1 then
					entity:AddPoison(EntityRef(player), 100, 3.5)
				end
			end
		end
	end
end

Isaac.DebugString("Hello world!")
GreenCandle:AddCallback(ModCallbacks.MC_POST_UPDATE, GreenCandle.onUpdate)