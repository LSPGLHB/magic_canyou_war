require('myMaths')
--打开商店界面
function OnMyUIShopOpen( PlayerID )
	--CustomUI:DynamicHud_Destroy(PlayerID,"UIShopBox")
	local hHero = PlayerResource:GetSelectedHeroEntity(PlayerID)
	EmitSoundOn("scene_voice_shop_open", hHero)
	CustomUI:DynamicHud_Create(PlayerID,"UIShopBox","file://{resources}/layout/custom_game/UI_shop.xml",nil)
end

function OnMyUIShopClose(PlayerID)
	local hHero = PlayerResource:GetSelectedHeroEntity(PlayerID)
	EmitSoundOn("scene_voice_shop_close", hHero)
	CustomUI:DynamicHud_Destroy(PlayerID,"UIShopBox")
end

function initItemList()
	local itemList = GameRules.itemList
	--print("itemListitemList",itemList)
	local itemNameList = {}
	local itemCostList = {}
	local itemTextureNameList = {}
	for name, item in pairs(itemList) do
		local itemName 
		local itemShowName
		local itemCost
		local itemTextureName
		local c = 0
		for key, value in pairs(item) do
			if key == "ItemType" and value == "equip" then
				itemName = name
				--print("itemName",itemName)
				c = c+1
			end

			if key == "ItemCost" then
				itemCost = value
				c = c+1
			end
			if key == "AbilityTextureName" then
				itemTextureName = value
				c = c+1
			end
			if c == 3 then
				table.insert(itemNameList,itemName)
				table.insert(itemCostList,itemCost)
				table.insert(itemTextureNameList,itemTextureName)
				break
			end
		end
	end
	GameRules.itemNameList = itemNameList
	GameRules.itemCostList = itemCostList
	GameRules.itemTextureNameList = itemTextureNameList
end

function getPlayerShopListByRandomList(playerID, randomNumList)
	local itemNameList = GameRules.itemNameList
	local itemCostList = GameRules.itemCostList
	local itemTextureNameList = GameRules.itemTextureNameList

	local randomItemNameList = getRandomArrayList(itemNameList, randomNumList)
	local randomItemCostList = getRandomArrayList(itemCostList, randomNumList)
	local randomItemTextureNameList = getRandomArrayList(itemTextureNameList, randomNumList)

	local listLength = #randomItemNameList
	--print("listLength",listLength)
	--local hHero = PlayerResource:GetSelectedHeroEntity(playerID)
	--EmitSoundOn("scene_voice_shop_refresh", hHero)
	CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(playerID), "getShopItemListLUATOJS", {
		num = listLength, 
		lock = playerShopLock[playerID],
		refreshCost = playerRefreshCost[playerID],
		randomItemNameList = randomItemNameList, 
		randomItemCostList = randomItemCostList,
		randomItemTextureNameList = randomItemTextureNameList
	})
end


function buyShopJSTOLUA(index,keys)
    local playerID = keys.PlayerID
	local num  = keys.num
	--local player = PlayerResource:GetPlayer(playerID)
	local hHero = PlayerResource:GetSelectedHeroEntity(playerID)
	local currentGold = PlayerResource:GetGold(playerID)
	
	local randomItemNumList = playerRandomItemNumList[playerID]
	local itemNameList = GameRules.itemNameList
	local itemCostList = GameRules.itemCostList
	--local itemTextureNameList = GameRules.itemTextureNameList
	local randomItemNameList = getRandomArrayList(itemNameList, randomItemNumList)
	local randomItemCostList = getRandomArrayList(itemCostList, randomItemNumList)
	--local randomItemTextureNameList = getRandomArrayList(itemTextureNameList, randomItemNumList)
	local itemName = randomItemNameList[num]
	local itemCost = randomItemCostList[num]
	--print("buyShopJSTOLUA",itemName)
	--CreateItem(itemName,player,player)
	local itemCount = hHero:GetNumItemsInInventory()
	--local stashCount = hHero:GetNumItemsInStash()
		if(currentGold >= itemCost) then
			if(itemCount < 9) then
				local ownerItem = CreateItem(itemName, hHero, hHero)
				hHero:AddItem(ownerItem)
				--DeepPrintTable(ownerItem)
				--hHero:AddItemByName(itemName)
				PlayerResource:SpendGold(playerID,itemCost,0)
				currentGold = PlayerResource:GetGold(playerID)
				EmitSoundOn("scene_voice_shop_buy", hHero)
				CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(playerID), "checkGoldLUATOJS", {
					playerGold = currentGold
				})
				playerRandomItemNumList[playerID][num] = -1
			else
				EmitSoundOn("scene_voice_player_disable", hHero)
				print("物品栏已满")
			end
		else
			EmitSoundOn("scene_voice_player_disable", hHero)
			print("金币不足")
		end
end


function lockShopJSTOLUA(index,keys)
	local playerID = keys.PlayerID
	--print("lockShopJSTOLUAF:"..playerShopLock[playerID])
	if playerShopLock[playerID] == 0 then
		playerShopLock[playerID] = 1
		return nil
	end
	if playerShopLock[playerID] == 1 then
		playerShopLock[playerID] = 0
		return nil
	end

end






