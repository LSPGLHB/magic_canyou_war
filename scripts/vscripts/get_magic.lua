require('myMaths')
function openUIMagicList( playerID )
	CustomUI:DynamicHud_Create(playerID,"UIMagicListPanelBox","file://{resources}/layout/custom_game/UI_magic_list.xml",nil)
end

function closeUIMagicList(playerID)
    CustomUI:DynamicHud_Destroy(playerID,"UIMagicListPanelBox")
end

--获取随机技能列表
function getRandomMagicList(playerID,MagicLevel,preMagic,listCount)
    local tempMagicNameList = GameRules.magicNameList
	local tempIconSrcList = GameRules.magicIconSrcList
	local tempShowNameList = GameRules.magicShowNameList
    local tempDescribeList = GameRules.magicDescribeList
	local tempPreMagicList = GameRules.preMagicList
	local tempMagicLvList = GameRules.magicLvList 

	local magicNameList ={}
	local iconSrcList = {}
	local showNameList = {}
    local describeList = {}
	local preMagicList = {}
	local magicLvList = {}
	
	--print("MagicLevel:",MagicLevel,"preMagic:",preMagic,"==")
	for i = 1 , #tempMagicNameList do
		--print("tempPreMagicList:",tempPreMagicList[i],"===","tempMagicLvList:",tempMagicLvList[i])
		if tempMagicLvList[i] ==  MagicLevel and tempPreMagicList[i] == preMagic then
			--print("tempPreMagicList:",tempPreMagicList[i],"=======================","tempMagicLvList:",tempMagicLvList[i])
			--print("tempMagicNameList:",tempMagicNameList[i],"=======================","tempIconSrcList:",tempIconSrcList[i])

			table.insert(magicNameList,tempMagicNameList[i])
			table.insert(iconSrcList,tempIconSrcList[i])
			table.insert(showNameList,tempShowNameList[i])
			table.insert(describeList,tempDescribeList[i])
			table.insert(preMagicList,tempPreMagicList[i])
			table.insert(magicLvList,tempMagicLvList[i])
		end
	end
	--local count = #magicNameList
	--[[查看传回数据
	print("magicNameList:count="..count)

	for i=1, #magicNameList do

		print("magicNameList=name="..magicNameList[i])
	end
	]]
	--随机数字数组
	local randomNumList= getRandomNumList(1,#magicNameList,listCount)
	--根据随机数字数组得出随机技能详细数组
    local randomNameList = getRandomArrayList(magicNameList, randomNumList)
	local randomIconList = getRandomArrayList(iconSrcList, randomNumList)
	local randomShowNameList = getRandomArrayList(showNameList, randomNumList)
    local randomDescribeList = getRandomArrayList(describeList, randomNumList)
	local randompreMagicList = getRandomArrayList(preMagicList, randomNumList)
    local randomMagicLvList = getRandomArrayList(magicLvList, randomNumList)
	RandomMagicNameList[playerID] = randomNameList

	local listLength = #randomNameList

	CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(playerID), "getRandomMagicListLUATOJS", {
        listLength=listLength, 
        magicNameList = randomNameList,
        magicIconList = randomIconList,
        magicShowNameList = randomShowNameList,
        magicDescribeList = randomDescribeList
    })
    
end
--测试用，流程不存在
function openMagicListPreCKVTOLUA(keys)
    local caster = keys.caster
	local playerID = caster:GetPlayerID()
	local preMagic = 'null'
	local MagicLevel = 'c'
    openUIMagicList( playerID )
    getRandomMagicList(playerID,MagicLevel,preMagic,3)
end

function openMagicListCKVTOLUA(keys)
	local caster = keys.caster
	local playerID = caster:GetPlayerID()
	local hHero = PlayerResource:GetSelectedHeroEntity(playerID)
	local preMagic = hHero:GetAbilityByIndex(3):GetAbilityName()
	local MagicLevel = 'c'
	openUIMagicList( playerID )
	getRandomMagicList(playerID,MagicLevel,preMagic,2)
end

function refreshMagicListJSTOLUA(index,keys)
    local playerID = keys.PlayerID
    closeUIMagicList(playerID)
    openUIMagicList(playerID)
	local preMagic = 'null'
	local MagicLevel = 'c'
    getRandomMagicList(playerID,MagicLevel,preMagic,3)
end

--启动打开选择页面
function openMagicListPreC(playerID)
	local preMagic = 'null'
	local MagicLevel = 'c'
    openUIMagicList( playerID )
    getRandomMagicList(playerID,MagicLevel,preMagic,3)
end

function openMagicListC(playerID)
	local hHero = PlayerResource:GetSelectedHeroEntity(playerID)
	local preMagic = hHero:GetAbilityByIndex(3):GetAbilityName()
	local MagicLevel = 'c'
	openUIMagicList( playerID )
	getRandomMagicList(playerID,MagicLevel,preMagic,2)
end

function openMagicListPreB(playerID)
	local preMagic = 'null'
	local MagicLevel = 'b'
    openUIMagicList( playerID )
    getRandomMagicList(playerID,MagicLevel,preMagic,3)
end

function openMagicListB(playerID)
	local hHero = PlayerResource:GetSelectedHeroEntity(playerID)
	local preMagic = hHero:GetAbilityByIndex(4):GetAbilityName()
	local MagicLevel = 'b'
	openUIMagicList( playerID )
	getRandomMagicList(playerID,MagicLevel,preMagic,2)
end

function openMagicListPreA(playerID)
	local preMagic = 'null'
	local MagicLevel = 'a'
    openUIMagicList( playerID )
    getRandomMagicList(playerID,MagicLevel,preMagic,3)
end

function openMagicListA(playerID)
	local hHero = PlayerResource:GetSelectedHeroEntity(playerID)
	local preMagic = hHero:GetAbilityByIndex(5):GetAbilityName()
	local MagicLevel = 'a'
	openUIMagicList( playerID )
	getRandomMagicList(playerID,MagicLevel,preMagic,2)
end


--关闭按钮
function closeMagicListJSTOLUA(index,keys)
    local playerID = keys.PlayerID
    closeUIMagicList(playerID)
end


function initMagicList()
	--初始化用于传递技能学习的列表
	RandomMagicNameList = {}
	for i = 1 , 10 do
		RandomMagicNameList[i]	= {}
	end

	--重新组装数组
	local magicList = GameRules.customAbilities
	local magicNameList = {}
	local iconSrcList = {}
	local showNameList = {}
    local describeList = {}
	local preMagicList = {}
	local magicLvList = {}
	
	--local flag = false
	for key, value in pairs(magicList) do
		--print("GetAbilityKV-----: ", key, value)
		--table.insert(magicNameList,key)	
		--flag = false
		local tempMagicLv
		local tempMagicName 
		local tempIconSrc 
		local tempShowName 
        local tempDescribe 
		local tempPreMagic 
		local c = 0
		for k,v in pairs(value) do
			if k == "AbilityLevel" then			
				tempMagicLv = v
				tempMagicName = key
				print("idName:"..key)
				c= c+1
			end
			if k == "IconSrc"  then
				tempIconSrc = v
				--print("icon:"..v)
				c = c+1
			end
			if k == "AbilityShowName"  then
				tempShowName = v
				--print("showName:"..v)
				c = c+1
			end	

            if k == "AbilityDescribe" then
                tempDescribe = v
                c= c+1
            end
			if k == "PreAbility" then
				tempPreMagic = v
				c= c+1
			end

			if c == 5 then
                --print("idName:"..tempMagicName)
				table.insert(magicNameList,tempMagicName)
				table.insert(iconSrcList,tempIconSrc)
				table.insert(showNameList,tempShowName)
				table.insert(describeList,tempDescribe)
				table.insert(preMagicList,tempPreMagic)
				table.insert(magicLvList,tempMagicLv)

				break
			end
		end
	end
    --print("listOVER",#magicNameList)
	GameRules.magicNameList = magicNameList
	GameRules.magicIconSrcList = iconSrcList
	GameRules.magicShowNameList = showNameList
    GameRules.magicDescribeList = describeList
	GameRules.preMagicList = preMagicList
	GameRules.magicLvList = magicLvList

end


--获得天赋
function learnMagicByNameJSTOLUA( index,keys )
    local playerID = keys.PlayerID
	local num  = keys.num
	learnMagicByNum(playerID, num)
end

function randomLearnMagic(gameRound)
	--1-3回合
	local roundCount
	if gameRound < 4 then
		roundCount = 3
	end

	if gameRound == 4 then
		roundCount = 6
	end

	if gameRound > 4 and gameRound < 8 then
		roundCount = 2
	end

	local learnNum = math.random(1,roundCount)

	for playerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
        if PlayerResource:GetConnectionState(playerID) == DOTA_CONNECTION_STATE_CONNECTED then
			if playerRoundLearn[playerID] == 0 then
				learnMagicByNum(playerID, learnNum)
			end
		end
	end
end

function learnMagicByNum(playerID, num)
	local player = PlayerResource:GetPlayer(playerID)
    local hHero = PlayerResource:GetSelectedHeroEntity(playerID)

    local magicName = RandomMagicNameList[playerID][num]
	local magicNameAllList = GameRules.magicNameList
	--local preMagicList = GameRules.preMagicList
	local magicLvList = GameRules.magicLvList
	local magicLv
	local abilityIndex
	for i = 1 , #magicNameAllList do
		if magicName == magicNameAllList[i] then
			magicLv = magicLvList[i]
		end
	end

	if magicLv == 'c' then
		abilityIndex = 3
	end
	if magicLv== 'b' then
		abilityIndex = 4
	end
	if magicLv == 'a' then
		abilityIndex = 5
	end

	local tempMagic = hHero:GetAbilityByIndex(abilityIndex):GetAbilityName()
	hHero:RemoveAbility(tempMagic) 
	hHero:AddAbility(magicName)
	hHero:FindAbilityByName(magicName):SetLevel(1)

	--标记已经学习技能
	playerRoundLearn[playerID] = 1
    closeUIMagicList(playerID)
end