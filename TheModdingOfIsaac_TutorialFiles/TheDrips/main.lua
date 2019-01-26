local DripsMod = RegisterMod("TheDrips", 1)
local game = Game()
local MIN_FIRE_DELAY = 5

-- The IDs of the various drips
local DripId = {
	SALINE = Isaac.GetItemIdByName("Saline Drip"),
	SLUDGE = Isaac.GetItemIdByName("Suspicious Drip"),
	K = Isaac.GetItemIdByName("Potassium Drip"),
	GLUCOSE = Isaac.GetItemIdByName("Glucose Drip"),
	DEW = Isaac.GetItemIdByName("Dewy Drip"),
	HELIUM = Isaac.GetItemIdByName("Helium Drip")
}

-- Does the player have any of the drips
local HasDrip = {
	Saline = false,
	Sludge = false,
	K = false,
	Glucose = false,
	Dew = false,
	Helium = false
}

-- How the drips affect the player's stats'
local DripBonus = {
	SALINE = 3,
	SLUDGE = 5,
	K = 0.5,
	GLUCOSE_TH = 1,
	GLUCOSE_FS = 1,
	GLUCOSE_SPEED = 0.5,
	DEW = 5
}

-- Pill: I'm Always Angry
local ImAlwaysAngry = {
	ID = Isaac.GetPillEffectByName("I'm Always Angry"),
	BONUS_DAMAGE = 7,
	BONUS_TH = 30,
	SCALE = Vector(1,1),
	IsAngry = false
}

-- Supposed to return pill color
ImAlwaysAngry.Color = Isaac.AddPillEffectToPool(ImAlwaysAngry.ID)

-- Checks if player has drips and updates table
local function UpdateDrips(player)
	HasDrip.Saline = player:HasCollectible(DripId.SALINE)
	HasDrip.Sludge = player:HasCollectible(DripId.SLUDGE)
	HasDrip.K = player:HasCollectible(DripId.K)
	HasDrip.Glucose = player:HasCollectible(DripId.GLUCOSE)
	HasDrip.Dew = player:HasCollectible(DripId.DEW)
	HasDrip.Helium = player:HasCollectible(DripId.HELIUM)
end

-- Checks to see if the player has any drips when initialized
function DripsMod:onPlayerInit(player)
	UpdateDrips(player)
end

DripsMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, DripsMod.onPlayerInit)

-- When passive effects should update
function DripsMod:onUpdate(player)

	-- Places the drips at the start of a run
	if game:GetFrameCount() == 1 then
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, DripId.SALINE, Vector(320,250), Vector(0,0), nil)
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, DripId.SLUDGE, Vector(270,250), Vector(0,0), nil)
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, DripId.K, Vector(220,250), Vector(0,0), nil)
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, DripId.GLUCOSE, Vector(370,250), Vector(0,0), nil)
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, DripId.HELIUM, Vector(420,250), Vector(0,0), nil)

		-- Allows Isaac to start with the "Dewy Drip"
		if player:GetName() == "Isaac" then
			player:AddCollectible(DripId.DEW, 0, true)
		end
	end
	
	UpdateDrips(player)

	-- Update our anger
	if ImAlwaysAngry.Room ~= nil and game:GetLevel():GetCurrentRoomIndex() ~= ImAlwaysAngry.Room then
		player:SetColor(Color(1.0,1.0,1.0,1.0,0.0,0.0,0.0),0,0,false,false)
		player.SpriteScale = ImAlwaysAngry.FormerScale
		ImAlwaysAngry.IsAngry = false
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
		player:AddCacheFlags(CacheFlag.CACHE_RANGE)
		player:EvaluateItems()
		ImAlwaysAngry.Room = nil
	end
end

DripsMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, DripsMod.onUpdate)

-- When the cache is updated
function DripsMod:onCache(player, cacheFlag)
	if cacheFlag == CacheFlag.CACHE_DAMAGE then
		if player:HasCollectible(DripId.SALINE) and not HasDrip.Saline then
			if player.MaxFireDelay >= MIN_FIRE_DELAY + DripBonus.SALINE then
				player.MaxFireDelay = player.MaxFireDelay - DripBonus.SALINE
			elseif player.MaxFireDelay >= MIN_FIRE_DELAY then
				player.MaxFireDelay = MIN_FIRE_DELAY
			end
		end
		if player:HasCollectible(DripId.SLUDGE) then
			player.Damage = player.Damage + DripBonus.SLUDGE
		end
		if ImAlwaysAngry.IsAngry then
			player.Damage = player.Damage + ImAlwaysAngry.BONUS_DAMAGE
		end
	end
	if cacheFlag == CacheFlag.CACHE_SHOTSPEED then
		if player:HasCollectible(DripId.K) then
			player.ShotSpeed = player.ShotSpeed + DripBonus.K
		end
	end
	if cacheFlag == CacheFlag.CACHE_RANGE then
		if player:HasCollectible(DripId.GLUCOSE) then
			player.TearHeight = player.TearHeight + DripBonus.GLUCOSE_TH
			player.TearFallingSpeed = player.TearFallingSpeed + DripBonus.GLUCOSE_FS
		end
		if ImAlwaysAngry.IsAngry then
			player.TearHeight = player.TearHeight - ImAlwaysAngry.BONUS_TH
		end
	end
	if cacheFlag == CacheFlag.CACHE_SPEED then
		if player:HasCollectible(DripId.GLUCOSE) then
			player.MoveSpeed = player.MoveSpeed + DripBonus.GLUCOSE_SPEED
		end
	end
	if cacheFlag == CacheFlag.CACHE_LUCK then
		if player:HasCollectible(DripId.DEW) then
			player.Luck = player.Luck + DripBonus.DEW
		end
	end
	if cacheFlag == CacheFlag.CACHE_FLYING then
		if player:HasCollectible(DripId.HELIUM) then
			player.CanFly = true
		end
	end
end

DripsMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, DripsMod.onCache)

-- I'm Alway Angry Proc code
function ImAlwaysAngry:Proc(_PillEffect)
	local player = game:GetPlayer(0)
	player:SetColor(Color(0.0,0.7,0.0,1.0,0.0,0.0,0.0),0,0,false,false)
	ImAlwaysAngry.FormerScale = player.SpriteScale
	player.SpriteScale = ImAlwaysAngry.FormerScale + ImAlwaysAngry.SCALE
	ImAlwaysAngry.Room = game:GetLevel():GetCurrentRoomIndex()
	ImAlwaysAngry.IsAngry = true
	player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
	player:AddCacheFlags(CacheFlag.CACHE_RANGE)
end

DripsMod:AddCallback(ModCallbacks.MC_USE_PILL, ImAlwaysAngry.Proc, ImAlwaysAngry.ID)