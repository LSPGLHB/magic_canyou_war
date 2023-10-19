require('myMaths')
function openUITalentList( playerID )
	CustomUI:DynamicHud_Create(playerID,"UITalentListPanelBox","file://{resources}/layout/custom_game/UI_talent_list.xml",nil)
end

function closeUITalentList(playerID)
    CustomUI:DynamicHud_Destroy(playerID,"UITalentListPanelBox")
end


--天赋随机列表
function getRandomTalentList(playerID, talentType)
    local randomNumList = getRandomNumList(1,#talentNameList[talentType],3)
    print("getRandomTalentList===============:"..playerID.."==="..talentType)
    RandomTalentNameList[playerID][talentType] = getRandomArrayList(talentNameList[talentType], randomNumList)
    RandomTalentTextureNameList[playerID][talentType]  = getRandomArrayList(talentTextureNameList[talentType], randomNumList)
    --RandomTalentDescribeList[playerID][talentType]  = getRandomArrayList(talentDescribeList[talentType], randomNumList)

    CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(playerID), "getRandomTalentListLUATOJS", {
        listLength = #RandomTalentNameList[playerID][talentType],
        talentType = talentType,
        nameList = RandomTalentNameList[playerID][talentType],
        textureNameList = RandomTalentTextureNameList[playerID][talentType]
        --describeList = RandomTalentDescribeList[playerID][talentType]
    })

end






--初始化天赋列表
function initTalentList()
    print("==================initTalentList================================")
    --公用数组随机列表
    RandomTalentNameList = {}
    RandomTalentTextureNameList= {}
    --RandomTalentDescribeList = {}

    playerTalentLearn = {}
    for i = 0, 9 do
        playerTalentLearn[i] = {}
        playerTalentLearn[i]['C'] = 'nil'
        playerTalentLearn[i]['B'] = 'nil'
        playerTalentLearn[i]['A'] = 'nil'
        RandomTalentNameList[i] = {}
        RandomTalentTextureNameList[i] = {}
        --RandomTalentDescribeList[i] = {}
        RandomTalentNameList[i]['C'] = {}
        RandomTalentTextureNameList[i]['C']= {}
        --RandomTalentDescribeList[i]['C'] = {}
        RandomTalentNameList[i]['B'] = {}
        RandomTalentTextureNameList[i]['B']= {}
        --RandomTalentDescribeList[i]['B'] = {}
        RandomTalentNameList[i]['A'] = {}
        RandomTalentTextureNameList[i]['A']= {}
        --RandomTalentDescribeList[i]['A'] = {}
    end
    --公用数组初始化
    talentNameList = {}
    talentTextureNameList = {}
    --talentDescribeList = {}
    talentNameList['C'] = {}
    talentTextureNameList['C']= {}
    --talentDescribeList['C'] = {}
    talentNameList['B'] = {}
    talentTextureNameList['B']= {}
    --talentDescribeList['B'] = {}
    talentNameList['A'] = {}
    talentTextureNameList['A']= {}
    --talentDescribeList['A'] = {}


    

    for key, value in pairs(GameRules.talentCList) do
        local talentCName = key
        --print("talentCName=========================================:"..talentCName)
        local talentCTextureName
        local talentCDescribe
        local c = 0
        for k,v in pairs(value) do
            if k == "AbilityTextureName" then
                talentCTextureName = v
                c = c + 1
            end
            --[[
            if k == "Describe" then
                talentCDescribe = v
                c = c + 1
            end]]
            if c == 1 then
                table.insert(talentNameList['C'],talentCName)
                table.insert(talentTextureNameList['C'],talentCTextureName)
                --table.insert(talentDescribeList['C'],talentCDescribe)
                break
            end
        end
    end

    for key, value in pairs(GameRules.talentBList) do
        local talentBName = key
        local talentBTextureName
        local talentBDescribe
        local c = 0
        for k,v in pairs(value) do
            if k == "AbilityTextureName" then
                talentBTextureName = v
                c = c + 1
            end
            --[[
            if k == "Describe" then
                talentBDescribe = v
                c = c + 1
            end]]
            if c == 1 then
                table.insert(talentNameList['B'],talentBName)
                table.insert(talentTextureNameList['B'],talentBTextureName)
                --table.insert(talentDescribeList['B'],talentBDescribe)
                break
            end
        end
    end

    for key, value in pairs(GameRules.talentAList) do
        local talentAName = key
        local talentATextureName
        local talentADescribe
        local c = 0
        for k,v in pairs(value) do
            if k == "AbilityTextureName" then
                talentATextureName = v
                c = c + 1
            end
            --[[
            if k == "Describe" then
                talentADescribe = v
                c = c + 1
            end]]
            if c == 1 then
                table.insert(talentNameList['A'],talentAName)
                table.insert(talentTextureNameList['A'],talentATextureName)
                --table.insert(talentDescribeList['A'],talentADescribe)
                break
            end
        end
    end


end




--测试用
function openTalentCListKVTOLUA(keys)
    local caster = keys.caster
	local playerID = caster:GetPlayerID()
   -- closeUITalentList(playerID)
    print("openTalentListKVTOLUA",playerID)
    openUITalentList( playerID )
    getRandomTalentList(playerID, "C")
end

function closeTalentListJSTOLUA(index,keys)
    local playerID = keys.PlayerID
    closeUITalentList(playerID)
end

function refreshTalentListJSTOLUA(index,keys)
    local playerID = keys.PlayerID
    closeUITalentList(playerID)
    openUITalentList(playerID)
    getRandomTalentCList(playerID)
end


--启动打开选择页面
function openRandomTalentCList(playerID)
    openUITalentList( playerID )
    getRandomTalentList(playerID,'C')
end

function openRandomTalentBList(playerID)
    openUITalentList( playerID )
    getRandomTalentList(playerID,'B')
end

function openRandomTalentAList(playerID)
    openUITalentList( playerID )
    getRandomTalentList(playerID,'A')
end

--随机天赋觉醒
function randomLearnTalent(gameRound)
	if gameRound == 9 then
		talentType = 'C'
	end
    if gameRound == 10 then
		talentType = 'B'
	end
    if gameRound == 11 then
		talentType = 'A'
	end
	local learnNum = math.random(1,3)

	for playerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
        if PlayerResource:GetConnectionState(playerID) == DOTA_CONNECTION_STATE_CONNECTED then
			if playerRoundLearn[playerID] == 0 or playerRoundLearn[playerID] == nil then
				learnTalentByNum(playerID, learnNum, talentType)
			end
		end
	end
end

--获得天赋
function learnTalentByNameJSTOLUA( index,keys )
    local playerID = keys.PlayerID
	local num  = keys.num
    local talentType = keys.talentType
    learnTalentByNum(playerID, num, talentType)
end

function learnTalentByNum(playerID, num, talentType)
	--local player = PlayerResource:GetPlayer(playerID)
    local hHero = PlayerResource:GetSelectedHeroEntity(playerID)
    local talentTag = 'talentName'..talentType



    local talentName = RandomTalentNameList[playerID][talentType][num]
    local talentTextureName = RandomTalentTextureNameList[playerID][talentType][num]
    --local talentDescribe = RandomTalentDescribeList[playerID][talentType][num]

    

    if playerTalentLearn[playerID][talentType] ~= 'nil' then
        local modifierName = "modifier_talent_"..playerTalentLearn[playerID][talentType].."_datadriven"
        hHero:RemoveModifierByName(modifierName)
        hHero:RemoveAbility(playerTalentLearn[playerID][talentType])
    end
    print("========talentName1=========:"..playerID..'='..talentType)
    --print("========talentName1=========:"..talentName..'='..talentDescribe)
    playerTalentLearn[playerID][talentType] = talentName
    hHero:AddAbility(talentName):SetLevel(1)
   

    CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(playerID), "setTalentUILUATOJS", {
        talentName = talentName,
        talentTextureName = talentTextureName,
        --talentDescribe = talentDescribe,
        talentType = talentType
    } )
    --标记已经学习技能
	playerRoundLearn[playerID] = 1
    closeUITalentList(playerID)
    heroStudyFinish(playerID)
end