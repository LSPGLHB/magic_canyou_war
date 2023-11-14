require('myMaths')
require('game_init')
function openUIContractList( playerID )
	CustomUI:DynamicHud_Create(playerID,"UIContractListPanelBox","file://{resources}/layout/custom_game/UI_contract_list.xml",nil)
end

function closeUIContractList(playerID)
    CustomUI:DynamicHud_Destroy(playerID,"UIContractListPanelBox")
end

--契约随机列表
function getRandomContractList(playerID)
    local count = GameRules.contractNameList 
    local randomContractNumList = getRandomNumList(1,#count,6)
    --GameRules.randomContractNumList = randomContractNumList
    --print("getRandomContractList:"..#count)

    local randomContractNameList  = getRandomArrayList(GameRules.contractNameList, randomContractNumList)
    local randomandomContractShowNameList = getRandomArrayList(GameRules.contractShowNameList, randomContractNumList)
    local randomContractDescribeList = getRandomArrayList(GameRules.contractDescribeList, randomContractNumList)

    RandomContractNameList[playerID] = randomContractNameList
    RandomContractShowNameList[playerID] = randomandomContractShowNameList
    RandomContractDescribeList[playerID] = randomContractDescribeList

    --OnUIContractListOpen( playerID )
    local listLength = #randomContractNumList

    CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(playerID), "getRandomContractListLUATOJS", {
        listLength = listLength,
        contractNameList = randomContractNameList,
        contractShowNameList = randomandomContractShowNameList,
        contractDescribeList = randomContractDescribeList
    })
end





--初始化契约列表
function initContractList()
    print("==================initContractList================================")

    --初始化用于传递技能学习的列表
	RandomContractNameList = {}
    RandomContractShowNameList = {}
    RandomContractDescribeList = {}

	for i = 0 , 9 do
		RandomContractNameList[i]	= {}
        RandomContractShowNameList[i]	= {}
        RandomContractDescribeList[i]	= {}
	end


    local contractList = GameRules.contractList
    local contractNameList = {}
    local contractShowNameList = {}
    local contractDescribeList = {}
    local playerContractLearn = {}

    for key, value in pairs(contractList) do
        local contractName = key
		local contractShowName = nil
        local contractDescribe = nil
		local c = 0
        for k,v in pairs(value) do
            if k == "ShowName"  then
                contractShowName = v
                c = c + 1
            end
            if k == "Describe" then
                contractDescribe = v
                c = c + 1
            end
            if c == 2 then
                --print("contractShowName",contractShowName)
                table.insert(contractNameList,contractName)
				table.insert(contractShowNameList,contractShowName)
                table.insert(contractDescribeList,contractDescribe)
                break
            end
        end
    end
    GameRules.contractNameList = contractNameList
    GameRules.contractShowNameList = contractShowNameList
    GameRules.contractDescribeList = contractDescribeList
end



--测试用
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


--启动打开选择页面
function openRandomContractList(playerID)
    openUIContractList( playerID )
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
	--local player = PlayerResource:GetPlayer(playerID)
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
    local contractDescribe = RandomContractDescribeList[playerID][num]

    if playerContractLearn[playerID]['contractName'] ~= 'nil' then
        local modifierName = "modifier_contract_"..playerContractLearn[playerID]['contractName'].."_datadriven"
        hHero:RemoveModifierByName(modifierName)
        hHero:RemoveAbility(playerContractLearn[playerID]['contractName'])
    end
    playerContractLearn[playerID]['contractName'] = contractName
    --print("contractName"..contractName)
    hHero:AddAbility(playerContractLearn[playerID]['contractName']):SetLevel(1)
   
    CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(playerID), "setContractUILUATOJS", {
        contractName = contractName,
        contractShowName = contractShowName,
        contractDescribe = contractDescribe
        
    } )
    --标记已经学习技能
	playerRoundLearn[playerID] = 1
    closeUIContractList(playerID)
    heroStudyFinish(playerID)
end


function closeKillCam()
    for playerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
        if PlayerResource:GetConnectionState(playerID) == DOTA_CONNECTION_STATE_CONNECTED then
			CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(playerID), "closeKillCamLUATOJS", {

                
            } )
		end
	end

end


