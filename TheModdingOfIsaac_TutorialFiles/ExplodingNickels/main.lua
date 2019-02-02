local ExplodingNickelsMod = RegisterMod("ExplodingNickels", 1)
local game = Game()


local ExplodingNickels = {
	QUANTITY = 5,
	RADIUS = 8,
	DELAY = 60,
	RED_SHIFT = Color(1.0, 0.0, 0.0, 1.0, 0, 0, 0),
	NO_SHIFT = Color(1.0, 1.0, 1.0, 1.0, 0, 0, 0),
	Target = nil
}


 -- If there are no exploding nickles, yet, check the room for a sticky nickle to change
function ExplodingNickels:onUpdate()
	if ExplodingNickels.Target == nil then
		local roomEntities = Isaac.GetRoomEntities()
		for i, entity in pairs(roomEntities) do
			if entity.Type == EntityType.ENTITY_PICKUP
				and entity.Variant == PickupVariant.PICKUP_COIN
				and entity.SubType == CoinSubType.COIN_STICKYNICKEL then
				ExplodingNickels.Target = entity
				ExplodingNickels.Frame = game:GetFrameCount() + ExplodingNickels.DELAY
			end
		end
	elseif game:GetFrameCount() == ExplodingNickels.Frame then
		for j = 1, ExplodingNickels.QUANTITY do
			Isaac.Spawn(
				EntityType.ENTITY_PICKUP,
				PickupVariant.PICKUP_COIN,
				CoinSubType.COIN_PENNY,
				ExplodingNickels.Target.Position,
				Vector(
					math.random(ExplodingNickels.RADIUS * 2 + 1) - ExplodingNickels.RADIUS,
					math.random(ExplodingNickels.RADIUS * 2 + 1) - ExplodingNickels.RADIUS
				),
				ExplodingNickels.Target
			)
		end
		Isaac.Explode(
			ExplodingNickels.Target.Position,
			ExplodingNickels.Target,
			10
		)
		ExplodingNickels.Target:Remove()
		ExplodingNickels.Target = nil
	elseif game:GetFrameCount() % 5 == 0 then
		if game:GetFrameCount() % 10 == 0 then
			ExplodingNickels.Target:SetColor(ExplodingNickels.NO_SHIFT, 0, 0, false, false)
		else
			ExplodingNickels.Target:SetColor(ExplodingNickels.RED_SHIFT, 0, 0, false, false)
		end
	end
end

ExplodingNickelsMod:AddCallback(ModCallbacks.MC_POST_UPDATE, ExplodingNickels.onUpdate)