require('myMaths')
function openUIContractList( playerID )
	CustomUI:DynamicHud_Create(playerID,"UIContractListPanelBox","file://{resources}/layout/custom_game/UI_contract_list.xml",nil)
end

function closeUIContractList(playerID)
    CustomUI:DynamicHud_Destroy(playerID,"UIContractListPanelBox")
end

function getRandomContractList(playerID)
    local count = GameRules.contractNameList 
    local randomContractNumList = getRandomNumList(1,#count,3)
    --GameRules.randomContractNumList = randomContractNumList
    print("getRandomContractList:"..#count)
    RandomContractNameList[playerID] = getRandomArrayList(GameRules.contractNameList, randomContractNumList)
    RandomContractShowNameList[playerID] = getRandomArrayList(GameRules.contractShowNameList, randomContractNumList)
    RandomContractIconList[playerID] = getRandomArrayList(GameRules.contractIconList, randomContractNumList)
    RandomContractDescribeList[playerID] = getRandomArrayList(GameRules.contractDescribeList, randomContractNumList)
    print(RandomContractNameList[playerID])
    --OnUIContractListOpen( playerID )
    local listLength = #randomContractNumList
    CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(playerID), "getRandomContractListLUATOJS", {
        listLength = listLength,
        contractNameList = RandomContractNameList[playerID],
        contractShowNameList = RandomContractShowNameList[playerID],
        contractIconList = RandomContractIconList[playerID],
        contractDescribeList = RandomContractDescribeList[playerID]
    })
end

--初始化天赋列表
function initContractList()
    print("==================initContractList================================")
    local contractList = GameRules.contractList
    local contractNameList = {}
    local contractShowNameList = {}
    local contractIconList = {}
    local contractDescribeList = {}

    --初始化用于传递技能学习的列表
	RandomContractNameList = {}
    RandomContractShowNameList = {}
    RandomContractIconList = {}
    RandomContractDescribeList = {}

	for i = 1 , 10 do
		RandomContractNameList[i]	= {}
        RandomContractShowNameList[i]	= {}
        RandomContractIconList[i]	= {}
        RandomContractDescribeList[i]	= {}
	end

    for key, value in pairs(contractList) do
        local contractName = key
		local contractShowName = nil
		local contractIcon = nil
        local contractDescribe = nil
		local c = 0
        for k,v in pairs(value) do
            if k == "ShowName"  then
                contractShowName = v
                c = c + 1
                
            end
            if k == "IconSrc" then
                contractIcon = v
                c = c + 1
            end
            if k == "Describe" then
                contractDescribe = v
                c = c + 1
            end
            if c == 3 then
                --print("contractShowName",contractShowName)
                table.insert(contractNameList,contractName)
				table.insert(contractShowNameList,contractShowName)
				table.insert(contractIconList,contractIcon)
                table.insert(contractDescribeList,contractDescribe)
                break
            end
        end
    end
    GameRules.contractNameList = contractNameList
    GameRules.contractShowNameList = contractShowNameList
    GameRules.contractIconList = contractIconList
    GameRules.contractDescribeList = contractDescribeList
end


--启动打开选择页面
function openContractListKVTOLUA(keys)
    local caster = keys.caster
	local playerID = caster:GetPlayerID()
   -- closeUIContractList(playerID)
   print("openContractListKVTOLUA",playerID)
    openUIContractList( playerID )
    getRandomContractList(playerID)
end

function closeContractListJSTOLUA(index,keys)
    local playerID = keys.PlayerID
    closeUIContractList(playerID)
end

function refreshContractListJSTOLUA(index,keys)
    local playerID = keys.PlayerID
    closeUIContractList(playerID)
    openUIContractList(playerID)
    getRandomContractList(playerID)
end

function randomLearnContract()
    local learnNum = math.random(1,3)

	for playerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
        if PlayerResource:GetConnectionState(playerID) == DOTA_CONNECTION_STATE_CONNECTED then
			if playerRoundLearn[playerID] == 0 then
				learnContractByNum(playerID, learnNum)
			end
		end
	end
end

--获得天赋
function learnContractByNameJSTOLUA( index,keys )
    local playerID = keys.PlayerID
	local num  = keys.num
    learnContractByNum(playerID, num)
end

function learnContractByNum(playerID, num)
	local player = PlayerResource:GetPlayer(playerID)
    local hHero = PlayerResource:GetSelectedHeroEntity(playerID)
    --[[
    local randomContractNumList = GameRules.randomContractNumList
    local contractNameList = getRandomArrayList(GameRules.contractNameList, randomContractNumList)
    local contractShowNameList = getRandomArrayList(GameRules.contractShowNameList, randomContractNumList)
    local contractIconList = getRandomArrayList(GameRules.contractIconList, randomContractNumList)
    local contractDescribeList = getRandomArrayList(GameRules.contractDescribeList, randomContractNumList)
    ]]
    local contractName = RandomContractNameList[playerID][num]
    local contractShowName = RandomContractShowNameList[playerID][num]
    local contractIcon = RandomContractIconList[playerID][num]
    local contractDescribe = RandomContractDescribeList[playerID][num]

    if player.contract ~= nil then
        local modifierName = "modifier_contract_"..player.contract.."_datadriven"
        hHero:RemoveModifierByName(modifierName)
        hHero:RemoveAbility(player.contract)
    end
    player.contract = contractName
    print("contractName"..contractName)
    hHero:AddAbility(player.contract):SetLevel(1)
   
    CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(playerID), "setContractUILUATOJS", {
        contractShowName = contractShowName,
        contractIcon = contractIcon,
        contractDescribe = contractDescribe
        
    } )
    --标记已经学习技能
	playerRoundLearn[playerID] = 1
    closeUIContractList(playerID)
end


function contractOperation(playerID)
    local player = PlayerResource:GetPlayer(playerID)
    local contractName = player.contract
    local contractList = GameRules.contractList

    for key, value in pairs(contractList) do
        if (contractName == key) then
            for k,v in pairs(value) do
                if k == "vision_bonus"  then
                    player.contract_vision_bonus = v
                end
                if k == "health_bonus" then
                    player.contract_speed_bouns = v
                end
                if k == "speed_bouns" then
                    player.contract_hp_reduce_precent_final = v
                end
            end
            --break;
        end
    end
end


