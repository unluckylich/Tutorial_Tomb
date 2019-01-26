local MyNewMod = RegisterMod("MyNewMod", 1)

function MyNewMod:immortality(_MyNewMod)
	local player = Isaac.GetPlayer(0)
	player:SetFullHearts()
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_LIL_BATTERY, 1, player.Position, player.Velocity, player)
end

MyNewMod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, MyNewMod.immortality, EntityType.ENTITY_PLAYER)