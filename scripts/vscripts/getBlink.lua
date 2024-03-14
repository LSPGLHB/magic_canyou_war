require('myMaths')
require('game_init')
require('myMaths')
require('game_init')
function openUIBlinkList( playerID )
	CustomUI:DynamicHud_Create(playerID,"UIBlinkListPanelBox","file://{resources}/layout/custom_game/UI_blink_list.xml",nil)
end

function closeUIBlinkList(playerID)
    CustomUI:DynamicHud_Destroy(playerID,"UIBlinkListPanelBox")
end

--契约随机列表
function getRandomBlinkList(playerID)
    local count = GameRules.blinkDataList 
    local randomBlinkNumList = getRandomNumList(1,#count,6)
    local randomBlinkList  = getRandomArrayList(GameRules.blinkDataList, randomBlinkNumList)
    RandomBlinkDataList[playerID] = randomBlinkList
    local listLength = #randomBlinkNumList

    CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(playerID), "getRandomBlinkListLUATOJS", {
        listLength = listLength,
        randomBlinkList = randomBlinkList
    })
end





--初始化契约列表
function initBlinkList()
    print("==================initBlinkList================================")

    --初始化用于传递技能学习的列表
	RandomBlinkDataList = {}

	for i = 0 , 9 do
		RandomBlinkDataList[i]	= {}
	end

    local blinkList = GameRules.blinkList
    local blinkDataList = {}
    local icount = 1
    for key, value in pairs(blinkList) do
        local blinkName = key
        local c = 0
        for k,v in pairs(value) do
            if k == "AbilityTextureName"  then
                srcPic = v
                c = c + 1
            end
            if c==1 then
                blinkDataList[icount] = {}
                blinkDataList[icount]['name'] = blinkName
                blinkDataList[icount]['srcPic'] = srcPic
                icount = icount + 1
                break
            end
        end
    end
    GameRules.blinkDataList = blinkDataList

end



--测试用
function openBlinkListKVTOLUA(keys)
    local caster = keys.caster
	local playerID = caster:GetPlayerID()
   -- closeUIBlinkList(playerID)
   print("openBlinkListKVTOLUA",playerID)
    openUIBlinkList( playerID )
    getRandomBlinkList(playerID)
end

function closeBlinkListJSTOLUA(index,keys)
    local playerID = keys.PlayerID
    closeUIBlinkList(playerID)
end

function refreshBlinkListJSTOLUA(index,keys)
    local playerID = keys.PlayerID
    closeUIBlinkList(playerID)
    openUIBlinkList(playerID)
    getRandomBlinkList(playerID)
end


--启动打开选择页面
function openRandomBlinkList(playerID)
    openUIBlinkList( playerID )
    getRandomBlinkList(playerID)
end


function randomlearnBlink()
    local learnNum = math.random(1,3)

	for playerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
        if PlayerResource:GetConnectionState(playerID) ~= DOTA_CONNECTION_STATE_UNKNOWN then
			if playerRoundLearn[playerID] == 0 then
				learnBlinkByNum(playerID, learnNum)
			end
		end
	end
end

--获得天赋
function learnBlinkByNameJSTOLUA( index,keys )
    local playerID = keys.PlayerID
	local num  = keys.num
    learnBlinkByNum(playerID, num)
end

function learnBlinkByNum(playerID, num)
	--local player = PlayerResource:GetPlayer(playerID)
    local hHero = PlayerResource:GetSelectedHeroEntity(playerID)
    local blinkName = RandomBlinkDataList[playerID][num]['name']

    if playerBlinkLearn[playerID]['name'] ~= 'nil' then
        local modifierName = playerBlinkLearn[playerID]['name'].."_passive"
        hHero:RemoveModifierByName(modifierName)
        --hHero:RemoveAbility(playerBlinkLearn[playerID]['name'])
    end

    playerBlinkLearn[playerID]['name'] = blinkName
    playerBlinkLearn[playerID]['srcPic'] = RandomBlinkDataList[playerID][num]['srcPic']
    --print("blinkName"..blinkName)
    local tempMagic = hHero:GetAbilityByIndex(5):GetAbilityName()
	hHero:RemoveAbility(tempMagic)
    hHero:AddAbility(playerBlinkLearn[playerID]['name']):SetLevel(1)

    --标记已经学习技能
	playerRoundLearn[playerID] = 1
    closeUIBlinkList(playerID)
    heroStudyFinish(playerID)
end




