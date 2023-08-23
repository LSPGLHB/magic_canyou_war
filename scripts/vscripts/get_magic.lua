require('myMaths')
function openUIMagicList( playerID )
	CustomUI:DynamicHud_Create(playerID,"UIMagicListPanelBox","file://{resources}/layout/custom_game/UI_magic_list.xml",nil)
end

function closeUIMagicList(playerID)
    CustomUI:DynamicHud_Destroy(playerID,"UIMagicListPanelBox")
end

function getMagicListFunc(playerID,MagicLevel,preMagic,listCount,functionForLUATOJS)
	local tempMagicNameList = magicList['magicNameList']
	local tempIconSrcList = magicList['magicIconSrcList']
	local tempPreMagicList = magicList['preMagicList']
	local tempMagicLvList = magicList['magicLvList']
	local tempUnitTypeList = magicList['unitTypeList']
	local magicNameList ={}
	local iconSrcList = {}
	--local showNameList = {}
   -- local describeList = {}
	local preMagicList = {}
	local magicLvList = {}
	--print("MagicLevel:",MagicLevel,"preMagic:",preMagic,"==")
	for i = 1 , #tempMagicNameList do
		--print("tempPreMagicList:",tempPreMagicList[i],"===","tempMagicLvList:",tempMagicLvList[i])
		--导入1-3回合技能表
		if tempMagicLvList[i] == MagicLevel and tempPreMagicList[i] == preMagic then
			--print("tempPreMagicList:",tempPreMagicList[i],"=======================","tempMagicLvList:",tempMagicLvList[i])
			--print("tempMagicNameList:",tempMagicNameList[i],"=======================","tempIconSrcList:",tempIconSrcList[i])
			table.insert(magicNameList,tempMagicNameList[i])
			table.insert(iconSrcList,tempIconSrcList[i])
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
	local randompreMagicList = getRandomArrayList(preMagicList, randomNumList)
    local randomMagicLvList = getRandomArrayList(magicLvList, randomNumList)

	RandomMagicNameList[playerID] = randomNameList

	local listLength = #randomNameList

	CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(playerID), functionForLUATOJS, {
        listLength=listLength, 
        magicNameList = randomNameList,
        magicIconList = randomIconList
    })
end

--获取随机技能列表
function getRandomMagicList(playerID,MagicLevel,preMagic,listCount)
    getMagicListFunc(playerID,MagicLevel,preMagic,listCount,"getRandomMagicListLUATOJS")  
end



function getRebuildRandomMagicList(playerID,MagicLevel,preMagic,listCount)
	getMagicListFunc(playerID,MagicLevel,preMagic,listCount,"getRebuildRandomMagicListLUATOJS")    
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

function openRebuildMagicList(playerID)
	openUIMagicList( playerID )
	getRebuildMagicList(playerID)
end

--打开重修列表
function openMagicListRebuild(playerID,num)
	openUIMagicList( playerID )
	local MagicLevel
	if num == 1 then
		MagicLevel = 'c'
	end
	if num == 2 then
		MagicLevel = 'b'
	end
	if num == 3 then
		MagicLevel = 'a'
	end
	getRebuildRandomMagicList(playerID,MagicLevel,"null",3)

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
	local magicTempList = GameRules.customAbilities
	magicList = {}

	magicList['magicNameList'] = {}
	magicList['iconSrcList'] = {}
	magicList['preMagicList'] = {}
	magicList['magicLvList'] = {}
	magicList['stageAbilityList'] = {}
	magicList['unitTypeList'] = {}
	--[[
	magicList[''] = {}
	magicList[''] = {}
	magicList[''] = {}
	magicList[''] = {}
	magicList[''] = {}
	magicList[''] = {}
	magicList[''] = {}
	magicList[''] = {}
	magicList[''] = {}]]

	local magicNameList = {}
	local iconSrcList = {}
	local preMagicList = {}
	local magicLvList = {}
	local stageAbilityList = {}
	local unitTypeList = {}

	local speedList_01 = {}
	local speedList_02 = {}
	local speedList_14 = {}

	local maxDistanceList_03 = {}
	local maxDistanceList_06 = {}
	local maxDistanceList_15 = {}

	local aoeRadiusList_04 = {}
	local aoeRadiusList_05 = {}

	local damageList_07 ={}
	local damageList_08 ={}
	
	local debuffDuration_21_36 = {}

	local aoeDuration_24_38 = {}

	local stunDebuffDuration_27 = {}


	
	--local flag = false
	for key, value in pairs(magicTempList) do
		--print("GetAbilityKV-----: ", key, value)

		local tempMagicLv
		local tempMagicName 
		local tempIconSrc 
		local tempPreMagic 
		local tempStageAbility
		local tempUnitType

		local tempSpeed = 'null'

		local c = 0
		for k,v in pairs(value) do
			if k == "AbilityLevel" then			
				tempMagicLv = v
				tempMagicName = key
				--print("idName:"..key)
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
			if k == "StageAbility" then
				tempStageAbility = v
				c= c+1
			end
			if k == "UnitType" then
				tempUnitType = v
				c= c+1
			end
			if k == "AbilitySpecial" then
				local tempAbilitySpecialList = v
				for x, y_table in pairs(tempAbilitySpecialList) do
					if x == "01" then
						for i,j_val in pairs(y_table) do

							if i == 'speed' then
								tempSpeed = j_val
							end
						end
					end


				end
				c=c+1
			end

			if c == 8 then
                --print("===============idName:"..tempMagicName.."speed:"..tempSpeed)
				table.insert(magicNameList,tempMagicName)
				table.insert(iconSrcList,tempIconSrc)
				table.insert(preMagicList,tempPreMagic)
				table.insert(magicLvList,tempMagicLv)
				table.insert(stageAbilityList,tempStageAbility)
				table.insert(unitTypeList,tempUnitType)

				table.insert(speedList_01,tempSpeed)


				
				break
			end
		end
	end
    --print("listOVER",#magicNameList)
	magicList['magicNameList'] = magicNameList
	magicList['magicIconSrcList'] = iconSrcList
	magicList['magicShowNameList'] = showNameList
    magicList['magicDescribeList'] = describeList
	magicList['preMagicList'] = preMagicList
	magicList['magicLvList'] = magicLvList
	
	magicList['stageAbilityList'] = stageAbilityList
	magicList['unitTypeList'] = unitTypeList

	--GameRules.speedList = speedList




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

	if gameRound > 4 and gameRound < 8 then
		roundCount = 2
	end

	local learnNum = math.random(1,roundCount)

	for playerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
        if PlayerResource:GetConnectionState(playerID) == DOTA_CONNECTION_STATE_CONNECTED then
			if playerRoundLearn[playerID] == 0 or playerRoundLearn[playerID] == nil then
				learnMagicByNum(playerID, learnNum)
			end
		end
	end
end

function learnMagicByNum(playerID, num)
	local player = PlayerResource:GetPlayer(playerID)
    local hHero = PlayerResource:GetSelectedHeroEntity(playerID)

    local magicName = RandomMagicNameList[playerID][num]
	local magicNameAllList = magicList['magicNameList']
	--local preMagicList = GameRules.preMagicList
	local magicLvList = magicList['magicLvList']
	local stageAbilityList = magicList['stageAbilityList']
	local magicLv
	local abilityIndex
	for i = 1 , #magicNameAllList do
		if magicName == magicNameAllList[i] then
			magicLv = magicLvList[i]
			stageAbility = stageAbilityList[i]
		end
	end

	if magicLv == 'c' then
		abilityIndex = 3
		stageAbilityIndex = 6
	end
	if magicLv== 'b' then
		abilityIndex = 4
		stageAbilityIndex = 7
	end
	if magicLv == 'a' then
		abilityIndex = 5
		stageAbilityIndex = 8
	end

	if stageAbility ~= 'null' then
		
		local tempStageMagic = hHero:GetAbilityByIndex(stageAbilityIndex):GetAbilityName()
		--print("tempStageMagic",tempStageMagic)
		--print("stageAbility",stageAbility)
		hHero:RemoveAbility(tempStageMagic) 
		hHero:AddAbility(stageAbility)	
		--hHero:FindAbilityByName(stageAbility):SetLevel(1)
	end
	local tempMagic = hHero:GetAbilityByIndex(abilityIndex):GetAbilityName()
	hHero:RemoveAbility(tempMagic) 
	hHero:AddAbility(magicName)
	hHero:FindAbilityByName(magicName):SetLevel(1)

	--标记已经学习技能
	playerRoundLearn[playerID] = 1
    closeUIMagicList(playerID)
end


--获取可遗忘法术列表
function getRebuildMagicList(playerID)
	local hHero = PlayerResource:GetSelectedHeroEntity(playerID)

	local magic_c = hHero:GetAbilityByIndex(3):GetAbilityName()
	local magic_b = hHero:GetAbilityByIndex(4):GetAbilityName()
	local magic_a = hHero:GetAbilityByIndex(5):GetAbilityName()

	local tempMagicNameList = magicList['magicNameList']
	local tempIconSrcList = magicList['magicIconSrcList']


	local rebuildNameList = {}
	local rebuildIconList = {}



	for i = 1 , #tempMagicNameList do
		local listNum = 0
		if tempMagicNameList[i] == magic_c then
			listNum = 1
		end
		if tempMagicNameList[i] == magic_b then
			listNum = 2
		end
		if tempMagicNameList[i] == magic_a then
			listNum = 3
		end

		if listNum ~= 0 then
			rebuildNameList[listNum] = tempMagicNameList[i]
			rebuildIconList[listNum] = tempIconSrcList[i]
		end
	end
	local listLength = #rebuildNameList

	CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(playerID), "getRebuildMagicListToForgetLUATOJS", {
		listLength=listLength, 
        magicNameList = rebuildNameList,
        magicIconList = rebuildIconList
    })
	
end


--打开重修魔法可选列表
function rebuildMagicByNameJSTOLUA( index,keys )
    local playerID = keys.PlayerID
	local num  = keys.num
	closeUIMagicList(playerID)
	openMagicListRebuild(playerID,num)
end

--根据重修的前置魔法，打开随机进阶魔法列表
function getRebuildMagicListByNameJSTOLUA( index,keys )
	local playerID = keys.PlayerID
	local num  = keys.num
	local magicName = RandomMagicNameList[playerID][num]
	local preMagic = magicName
	local magicNameAllList = magicList['magicNameList']
	--local preMagicList = GameRules.preMagicList 
	local magicLvList = magicList['magicLvList']
	local MagicLevel
	for i = 1, #magicNameAllList do
		if magicNameAllList[i] == magicName then
			MagicLevel = magicLvList[i]
		end
	end

	closeUIMagicList(playerID)
	openUIMagicList( playerID )
	getRandomMagicList(playerID,MagicLevel,preMagic,2)

end
