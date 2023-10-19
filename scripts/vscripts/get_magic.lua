require('myMaths')
function openUIMagicList( playerID )
	CustomUI:DynamicHud_Create(playerID,"UIMagicListPanelBox","file://{resources}/layout/custom_game/UI_magic_list.xml",nil)
end

function closeUIMagicList(playerID)
    CustomUI:DynamicHud_Destroy(playerID,"UIMagicListPanelBox")
end

function getMagicListFunc(playerID,MagicLevel,preMagic,listCount,functionForLUATOJS)

	local magicNameList ={}
	local abilityCooldownList = {}
	local abilityManaCostList = {}
	local iconSrcList = {}
	local preMagicList = {}
	local magicLvList = {}
	local stageAbilityList = {}
	local unitTypeList = {}

	local speedList_01 = {}
	local speedList_02 = {}
	local speedList_14 = {}
	local maxDistanceList_03 = {}
	local aoeRadiusList_04 = {}
	local aoeRadiusList_05 = {}
	local maxDistanceList_06 = {}
	local maxDistanceList_15 = {}
	local damageList_07 = {}
	local damageList_08 = {}
	local damageList_09 = {}
	local maxChargesList_10 = {}
	local chargeReplenishTimeList_11 = {}
	local energyList_12 = {}
	local energyList_13 = {}
	local debuffDurationList_21 = {}
	local beatBackDistanceList_22 = {}
	local debuffDurationList_23 = {}
	local aoeDurationList_24 = {}
	local debuffDurationList_25 = {}
	local debuffDurationList_26 = {}
	local stunDebuffDurationList_27 = {}
	local sleepDebuffDurationList_28 = {}
	local aoeDurationList_29 = {}
	local debuffDurationList_30 = {}
	local aoeDurationList_31 = {}
	local debuffDurationList_32 = {}
	local debuffDurationList_33 = {}
	local debuffDurationList_34 = {}
	local aoeDurationList_35 = {}
	local debuffDurationList_36 = {}
	local GSpeedList_37 = {}
	local aoeDurationList_38 = {}
	local boomDelayList_50 = {}
	local visionRadiusList_51 = {}
	local aoeDurationList_52 = {}
	local debuffDurationList_53 = {}
	local aoeDurationList_54 = {}
	local visionTimeList_55 = {}
	local debuffDelayList_56 = {}
	local debuffDurationList_57 = {}
	local searchRangeList_58 = {}
	local doubleDamagePercentageList_59 = {}
	local bounsDamagePercentageList_60 = {}
	local sendDelayList_61 = {}
	local chargeTimeList_62 = {}
	local turnRatePercentList_63 = {}
	local speedPercentList_64 = {}
	local channelTimeList_65 = {}
	local stageDurationList_66 = {}
	local debuffSpeedPercentList_67 = {}
	local bounsDamagePercentageList_68 = {}
	local debuffDurationList_69 = {}
	local aoeRadiusList_70 = {}
	local damageByDistanceList_71 = {}
	local diffuseSpeedList_72 = {}
	local catchRadiusList_75 = {}
	local windSpeedList_76 = {}
	local windDamagePercentList_77 = {}
	local boundsDamagePercentList_78 = {}
	local windSpeedList_79 = {}
	local boundsDamageList_80 = {}
	local boundsDamageCountList_81 = {}
	local shootCountList_82 = {}
	local GSpeedList_83 = {}

	--print("MagicLevel:",MagicLevel,"preMagic:",preMagic,"==")
	for i = 1 , #magicList['magicNameList'] do
		--print("tempPreMagicList:",tempPreMagicList[i],"===","tempMagicLvList:",tempMagicLvList[i])
		--导入1-3回合技能表
		if magicList['magicLvList'][i] == MagicLevel and  magicList['preMagicList'][i] == preMagic then
			--print("tempPreMagicList:",tempPreMagicList[i],"=======================","tempMagicLvList:",tempMagicLvList[i])
			--print("tempMagicNameList:",tempMagicNameList[i],"=======================","tempIconSrcList:",tempIconSrcList[i])
			table.insert(magicNameList,magicList['magicNameList'][i])
			table.insert(abilityCooldownList,magicList['abilityCooldownList'][i])
			table.insert(abilityManaCostList,magicList['abilityManaCostList'][i])
			table.insert(iconSrcList,magicList['magicIconSrcList'][i])
			table.insert(preMagicList,magicList['preMagicList'][i])
			table.insert(magicLvList,magicList['magicLvList'][i])
			table.insert(stageAbilityList,magicList['stageAbilityList'][i])
			table.insert(unitTypeList,magicList['unitTypeList'][i])

			table.insert(speedList_01,magicList['speedList_01'][i])
			table.insert(speedList_02,magicList['speedList_02'][i])
			table.insert(speedList_14,magicList['speedList_14'][i])
			table.insert(maxDistanceList_03,magicList['maxDistanceList_03'][i])
			table.insert(aoeRadiusList_04,magicList['aoeRadiusList_04'][i])
			table.insert(aoeRadiusList_05,magicList['aoeRadiusList_05'][i])
			table.insert(maxDistanceList_06,magicList['maxDistanceList_06'][i])
			table.insert(maxDistanceList_15,magicList['maxDistanceList_15'][i])
			table.insert(damageList_07,magicList['damageList_07'][i])
			table.insert(damageList_08,magicList['damageList_08'][i])
			table.insert(damageList_09,magicList['damageList_09'][i])
			table.insert(maxChargesList_10,magicList['maxChargesList_10'][i])
			table.insert(chargeReplenishTimeList_11,magicList['chargeReplenishTimeList_11'][i])
			table.insert(energyList_12,magicList['energyList_12'][i])
			table.insert(energyList_13,magicList['energyList_13'][i])
			table.insert(debuffDurationList_21,magicList['debuffDurationList_21'][i])
			table.insert(beatBackDistanceList_22,magicList['beatBackDistanceList_22'][i])
			table.insert(debuffDurationList_23,magicList['debuffDurationList_23'][i])
			table.insert(aoeDurationList_24,magicList['aoeDurationList_24'][i])
			table.insert(debuffDurationList_25,magicList['debuffDurationList_25'][i])
			table.insert(debuffDurationList_26,magicList['debuffDurationList_26'][i])
			table.insert(stunDebuffDurationList_27,magicList['stunDebuffDurationList_27'][i])
			table.insert(sleepDebuffDurationList_28,magicList['sleepDebuffDurationList_28'][i])
			table.insert(aoeDurationList_29,magicList['aoeDurationList_29'][i])
			table.insert(debuffDurationList_30,magicList['debuffDurationList_30'][i])
			table.insert(aoeDurationList_31,magicList['aoeDurationList_31'][i])
			table.insert(debuffDurationList_32,magicList['debuffDurationList_32'][i])
			table.insert(debuffDurationList_33,magicList['debuffDurationList_33'][i])
			table.insert(debuffDurationList_34,magicList['debuffDurationList_34'][i])
			table.insert(aoeDurationList_35,magicList['aoeDurationList_35'][i])
			table.insert(debuffDurationList_36,magicList['debuffDurationList_36'][i])
			table.insert(GSpeedList_37,magicList['GSpeedList_37'][i])
			table.insert(aoeDurationList_38,magicList['aoeDurationList_38'][i])
			table.insert(boomDelayList_50,magicList['boomDelayList_50'][i])
			table.insert(visionRadiusList_51,magicList['visionRadiusList_51'][i])
			table.insert(aoeDurationList_52,magicList['aoeDurationList_52'][i])
			table.insert(debuffDurationList_53,magicList['debuffDurationList_53'][i])
			table.insert(aoeDurationList_54,magicList['aoeDurationList_54'][i])
			table.insert(visionTimeList_55,magicList['visionTimeList_55'][i])
			table.insert(debuffDelayList_56,magicList['debuffDelayList_56'][i])
			table.insert(debuffDurationList_57,magicList['debuffDurationList_57'][i])
			table.insert(searchRangeList_58,magicList['searchRangeList_58'][i])
			table.insert(doubleDamagePercentageList_59,magicList['doubleDamagePercentageList_59'][i])
			table.insert(bounsDamagePercentageList_60,magicList['bounsDamagePercentageList_60'][i])
			table.insert(sendDelayList_61,magicList['sendDelayList_61'][i])
			table.insert(chargeTimeList_62,magicList['chargeTimeList_62'][i])
			table.insert(turnRatePercentList_63,magicList['turnRatePercentList_63'][i])
			table.insert(speedPercentList_64,magicList['speedPercentList_64'][i])
			table.insert(channelTimeList_65,magicList['channelTimeList_65'][i])
			table.insert(stageDurationList_66,magicList['stageDurationList_66'][i])
			table.insert(debuffSpeedPercentList_67,magicList['debuffSpeedPercentList_67'][i])
			table.insert(bounsDamagePercentageList_68,magicList['bounsDamagePercentageList_68'][i])
			table.insert(debuffDurationList_69,magicList['debuffDurationList_69'][i])
			table.insert(aoeRadiusList_70,magicList['aoeRadiusList_70'][i])
			table.insert(damageByDistanceList_71,magicList['damageByDistanceList_71'][i])
			table.insert(diffuseSpeedList_72,magicList['diffuseSpeedList_72'][i])
			table.insert(catchRadiusList_75,magicList['catchRadiusList_75'][i])
			table.insert(windSpeedList_76,magicList['windSpeedList_76'][i])
			table.insert(windDamagePercentList_77,magicList['windDamagePercentList_77'][i])
			table.insert(boundsDamagePercentList_78,magicList['boundsDamagePercentList_78'][i])
			table.insert(windSpeedList_79,magicList['windSpeedList_79'][i])
			table.insert(boundsDamageList_80,magicList['boundsDamageList_80'][i])
			table.insert(boundsDamageCountList_81,magicList['boundsDamageCountList_81'][i])
			table.insert(shootCountList_82,magicList['shootCountList_82'][i])
			table.insert(GSpeedList_83,magicList['GSpeedList_83'][i])
		end
	end

	--随机数字数组
	local randomNumList= getRandomNumList(1,#magicNameList,listCount)
	--根据随机数字数组得出随机技能详细数组
    local randomNameList = getRandomArrayList(magicNameList, randomNumList)
	local randomAbilityCooldownList = getRandomArrayList(abilityCooldownList, randomNumList)
	local randomAbilityManaCostList = getRandomArrayList(abilityManaCostList, randomNumList)
	local randomIconList = getRandomArrayList(iconSrcList, randomNumList)
	local randompreMagicList = getRandomArrayList(preMagicList, randomNumList)
    local randomMagicLvList = getRandomArrayList(magicLvList, randomNumList)
	local randomUnitTypeList = getRandomArrayList(unitTypeList, randomNumList)
	local randomSpeedList_01 = getRandomArrayList(speedList_01, randomNumList)
	local randomSpeedList_02 = getRandomArrayList(speedList_02, randomNumList)
	local randomSpeedList_14 = getRandomArrayList(speedList_14, randomNumList)
	local randomMaxDistanceList_03 = getRandomArrayList(maxDistanceList_03, randomNumList)
	local randomAoeRadiusList_04 = getRandomArrayList(aoeRadiusList_04, randomNumList)
	local randomAoeRadiusList_05 = getRandomArrayList(aoeRadiusList_05, randomNumList)
	local randomMaxDistanceList_06 = getRandomArrayList(maxDistanceList_06, randomNumList)
	local randomMaxDistanceList_15 = getRandomArrayList(maxDistanceList_15, randomNumList)
	local randomDamageList_07 = getRandomArrayList(damageList_07, randomNumList)
	local randomDamageList_08 = getRandomArrayList(damageList_08, randomNumList)
	local randomDamageList_09 = getRandomArrayList(damageList_09, randomNumList)
	local randomMaxChargesList_10 = getRandomArrayList(maxChargesList_10, randomNumList)
	local randomChargeReplenishTimeList_11 = getRandomArrayList(chargeReplenishTimeList_11, randomNumList)
	local randomEnergyList_12 = getRandomArrayList(energyList_12, randomNumList)
	local randomEnergyList_13 = getRandomArrayList(energyList_13, randomNumList)
	local randomDebuffDurationList_21 = getRandomArrayList(debuffDurationList_21, randomNumList)
	local randomBeatBackDistanceList_22 = getRandomArrayList(beatBackDistanceList_22, randomNumList)
	local randomDebuffDurationList_23 = getRandomArrayList(debuffDurationList_23, randomNumList)
	local randomAoeDurationList_24 = getRandomArrayList(aoeDurationList_24, randomNumList)
	local randomDebuffDurationList_25 = getRandomArrayList(debuffDurationList_25, randomNumList)
	local randomDebuffDurationList_26 = getRandomArrayList(debuffDurationList_26, randomNumList)
	local randomStunDebuffDurationList_27 = getRandomArrayList(stunDebuffDurationList_27, randomNumList)
	local randomSleepDebuffDurationList_28 = getRandomArrayList(sleepDebuffDurationList_28, randomNumList)
	local randomAoeDurationList_29 = getRandomArrayList(aoeDurationList_29, randomNumList)
	local randomDebuffDurationList_30 = getRandomArrayList(debuffDurationList_30, randomNumList)
	local randomAoeDurationList_31 = getRandomArrayList(aoeDurationList_31, randomNumList)
	local randomDebuffDurationList_32 = getRandomArrayList(debuffDurationList_32, randomNumList)
	local randomDebuffDurationList_33 = getRandomArrayList(debuffDurationList_33, randomNumList)
	local randomDebuffDurationList_34 = getRandomArrayList(debuffDurationList_34, randomNumList)
	local randomAoeDurationList_35 = getRandomArrayList(aoeDurationList_35, randomNumList)
	local randomDebuffDurationList_36 = getRandomArrayList(debuffDurationList_36, randomNumList)
	local randomGSpeedList_37 = getRandomArrayList(GSpeedList_37, randomNumList)
	local randomAoeDurationList_38 = getRandomArrayList(aoeDurationList_38, randomNumList)
	local randomBoomDelayList_50 = getRandomArrayList(boomDelayList_50, randomNumList)
	local randomVisionRadiusList_51 = getRandomArrayList(visionRadiusList_51, randomNumList)
	local randomAoeDurationList_52 = getRandomArrayList(aoeDurationList_52, randomNumList)
	local randomDebuffDurationList_53 = getRandomArrayList(debuffDurationList_53, randomNumList)
	local randomAoeDurationList_54 = getRandomArrayList(aoeDurationList_54, randomNumList)
	local randomVisionTimeList_55 = getRandomArrayList(visionTimeList_55, randomNumList)
	local randomDebuffDelayList_56 = getRandomArrayList(debuffDelayList_56, randomNumList)
	local randomDebuffDurationList_57 = getRandomArrayList(debuffDurationList_57, randomNumList)
	local randomSearchRangeList_58 = getRandomArrayList(searchRangeList_58, randomNumList)
	local randomDoubleDamagePercentageList_59 = getRandomArrayList(doubleDamagePercentageList_59, randomNumList)
	local randomBounsDamagePercentageList_60 = getRandomArrayList(bounsDamagePercentageList_60, randomNumList)
	local randomSendDelayList_61 = getRandomArrayList(sendDelayList_61, randomNumList)
	local randomChargeTimeList_62 = getRandomArrayList(chargeTimeList_62, randomNumList)
	local randomTurnRatePercentList_63 = getRandomArrayList(turnRatePercentList_63, randomNumList)
	local randomSpeedPercentList_64 = getRandomArrayList(speedPercentList_64, randomNumList)
	local randomChannelTimeList_65 = getRandomArrayList(channelTimeList_65, randomNumList)
	local randomStageDurationList_66 = getRandomArrayList(stageDurationList_66, randomNumList)
	local randomDebuffSpeedPercentList_67 = getRandomArrayList(debuffSpeedPercentList_67, randomNumList)
	local randomBounsDamagePercentageList_68 = getRandomArrayList(bounsDamagePercentageList_68, randomNumList)
	local randomDebuffDurationList_69 = getRandomArrayList(debuffDurationList_69, randomNumList)
	local randomAoeRadiusList_70 = getRandomArrayList(aoeRadiusList_70, randomNumList)
	local randomDamageByDistanceList_71 = getRandomArrayList(damageByDistanceList_71, randomNumList)
	local randomDiffuseSpeedList_72 = getRandomArrayList(diffuseSpeedList_72, randomNumList)
	local randomCatchRadiusList_75 = getRandomArrayList(catchRadiusList_75, randomNumList)
	local randomWindSpeedList_76 = getRandomArrayList(windSpeedList_76, randomNumList)
	local randomWindDamagePercentList_77 = getRandomArrayList(windDamagePercentList_77, randomNumList)
	local randomBoundsDamagePercentList_78 = getRandomArrayList(boundsDamagePercentList_78, randomNumList)
	local randomWindSpeedList_79 = getRandomArrayList(windSpeedList_79, randomNumList)
	local randomBoundsDamageList_80 = getRandomArrayList(boundsDamageList_80, randomNumList)
	local randomBoundsDamageCountList_81 = getRandomArrayList(boundsDamageCountList_81, randomNumList)
	local randomShootCountList_82 = getRandomArrayList(shootCountList_82, randomNumList)
	local randomGSpeedList_83 = getRandomArrayList(GSpeedList_83, randomNumList)

	RandomMagicNameList[playerID] = randomNameList

	local listLength = #randomNameList

	local titleLvl
	local titleType
	local titleValue
	if MagicLevel == 'c' then
		titleLvl = "初级"
	end
	if MagicLevel == 'b' then
		titleLvl = "中级"
	end
	if MagicLevel == 'a' then
		titleLvl = "高级"
	end

	if preMagic == 'null' then
		titleType = "学习"
	end
	if preMagic ~= 'null' then
		titleType = "进阶"
	end
	titleValue = "选择"..titleType.."一个"..titleLvl.."技能"
	--print("titleValue:"..titleValue)
	CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(playerID), functionForLUATOJS, {
        listLength=listLength, 
		titleValue = titleValue,
        magicNameList = randomNameList,
		abilityCooldownList = randomAbilityCooldownList,
		abilityManaCostList = randomAbilityManaCostList,
        magicIconList = randomIconList,
		preMagicList = randompreMagicList,
		magicLvList = randomMagicLvList,
		unitTypeList = randomUnitTypeList,
		speedList_01 = randomSpeedList_01,
		speedList_02 = randomSpeedList_02,
		speedList_14 = randomSpeedList_14,
		maxDistanceList_03 = randomMaxDistanceList_03,
		aoeRadiusList_04 = randomAoeRadiusList_04,
		aoeRadiusList_05 = randomAoeRadiusList_05,
		maxDistanceList_06 = randomMaxDistanceList_06,
		maxDistanceList_15 = randomMaxDistanceList_15,
		damageList_07 = randomDamageList_07,
		damageList_08 = randomDamageList_08,
		damageList_09 = randomDamageList_09,
		maxChargesList_10 = randomMaxChargesList_10,
		chargeReplenishTimeList_11 = randomChargeReplenishTimeList_11,
		energyList_12 = randomEnergyList_12,
		energyList_13 = randomEnergyList_13,
		debuffDurationList_21 = randomDebuffDurationList_21,
		beatBackDistanceList_22 = randomBeatBackDistanceList_22,
		debuffDurationList_23 = randomDebuffDurationList_23,
		aoeDurationList_24 = randomAoeDurationList_24,
		debuffDurationList_25 = randomDebuffDurationList_25,
		debuffDurationList_26 = randomDebuffDurationList_26,
		stunDebuffDurationList_27 = randomStunDebuffDurationList_27,
		sleepDebuffDurationList_28 = randomSleepDebuffDurationList_28,
		aoeDurationList_29 = randomAoeDurationList_29,
		debuffDurationList_30 = randomDebuffDurationList_30,
		aoeDurationList_31 = randomAoeDurationList_31,
		debuffDurationList_32 = randomDebuffDurationList_32,
		debuffDurationList_33 = randomDebuffDurationList_33,
		debuffDurationList_34 = randomDebuffDurationList_34,
		aoeDurationList_35 = randomAoeDurationList_35,
		debuffDurationList_36 = randomDebuffDurationList_36,
		GSpeedList_37 = randomGSpeedList_37,
		aoeDurationList_38 = randomAoeDurationList_38,
		boomDelayList_50 = randomBoomDelayList_50,
		visionRadiusList_51 = randomVisionRadiusList_51,
		aoeDurationList_52 = randomAoeDurationList_52,
		debuffDurationList_53 = randomDebuffDurationList_53,
		aoeDurationList_54 = randomAoeDurationList_54,
		visionTimeList_55 = randomVisionTimeList_55,
		debuffDelayList_56 = randomDebuffDelayList_56,
		debuffDurationList_57 = randomDebuffDurationList_57,
		searchRangeList_58 = randomSearchRangeList_58,
		doubleDamagePercentageList_59 = randomDoubleDamagePercentageList_59,
		bounsDamagePercentageList_60 = randomBounsDamagePercentageList_60,
		sendDelayList_61 = randomSendDelayList_61,
		chargeTimeList_62 = randomChargeTimeList_62,
		turnRatePercentList_63 = randomTurnRatePercentList_63,
		speedPercentList_64 = randomSpeedPercentList_64,
		channelTimeList_65 = randomChannelTimeList_65,
		stageDurationList_66 = randomStageDurationList_66,
		debuffSpeedPercentList_67 = randomDebuffSpeedPercentList_67,
		bounsDamagePercentageList_68 = randomBounsDamagePercentageList_68,
		debuffDurationList_69 = randomDebuffDurationList_69,
		aoeRadiusList_70 = randomAoeRadiusList_70,
		damageByDistanceList_71 = randomDamageByDistanceList_71,
		diffuseSpeedList_72 = randomDiffuseSpeedList_72,
		catchRadiusList_75 = randomCatchRadiusList_75,
		windSpeedList_76 = randomWindSpeedList_76,
		windDamagePercentList_77 = randomWindDamagePercentList_77,
		boundsDamagePercentList_78 = randomBoundsDamagePercentList_78,
		windSpeedList_79 = randomWindSpeedList_79,
		boundsDamageList_80 = randomBoundsDamageList_80,
		boundsDamageCountList_81 = randomBoundsDamageCountList_81,
		shootCountList_82 = randomShootCountList_82,
		GSpeedList_83 = randomGSpeedList_83
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
	local MagicLevel = 'b'
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
	getRandomMagicList(playerID,MagicLevel,preMagic,3)
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
	getRandomMagicList(playerID,MagicLevel,preMagic,3)
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
	getRandomMagicList(playerID,MagicLevel,preMagic,3)
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
	getRandomMagicList(playerID,MagicLevel,preMagic,3)
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
	magicList['abilityCooldownList'] = {}
	magicList['abilityManaCostList'] = {}
	magicList['magicIconSrcList'] = {}
	magicList['preMagicList'] = {}
	magicList['magicLvList'] = {}
	magicList['stageAbilityList'] = {}
	magicList['unitTypeList'] = {}

	magicList['speedList_01'] = {}
	magicList['speedList_02'] = {}
	magicList['speedList_14'] = {}
	magicList['maxDistanceList_03'] = {}
	magicList['aoeRadiusList_04'] = {}
	magicList['aoeRadiusList_05'] = {}
	magicList['maxDistanceList_06'] = {}
	magicList['maxDistanceList_15'] = {}
	magicList['damageList_07'] = {}
	magicList['damageList_08'] = {}
	magicList['damageList_09'] = {}
	magicList['maxChargesList_10'] = {}
	magicList['chargeReplenishTimeList_11'] = {}
	magicList['energyList_12'] = {}
	magicList['energyList_13'] = {}
	magicList['debuffDurationList_21'] = {}
	magicList['beatBackDistanceList_22'] = {}
	magicList['debuffDurationList_23'] = {}
	magicList['aoeDurationList_24'] = {}
	magicList['debuffDurationList_25'] = {}
	magicList['debuffDurationList_26'] = {}
	magicList['stunDebuffDurationList_27'] = {}
	magicList['sleepDebuffDurationList_28'] = {}
	magicList['aoeDurationList_29'] = {}
	magicList['debuffDurationList_30'] = {}
	magicList['aoeDurationList_31'] = {}
	magicList['debuffDurationList_32'] = {}
	magicList['debuffDurationList_33'] = {}
	magicList['debuffDurationList_34'] = {}
	magicList['aoeDurationList_35'] = {}
	magicList['debuffDurationList_36'] = {}
	magicList['GSpeedList_37'] = {}
	magicList['aoeDurationList_38'] = {}
	magicList['boomDelayList_50'] = {}
	magicList['visionRadiusList_51'] = {}
	magicList['aoeDurationList_52'] = {}
	magicList['debuffDurationList_53'] = {}
	magicList['aoeDurationList_54'] = {}
	magicList['visionTimeList_55'] = {}
	magicList['debuffDelayList_56'] = {}
	magicList['debuffDurationList_57'] = {}
	magicList['searchRangeList_58'] = {}
	magicList['doubleDamagePercentageList_59'] = {}
	magicList['bounsDamagePercentageList_60'] = {}
	magicList['sendDelayList_61'] = {}
	magicList['chargeTimeList_62'] = {}
	magicList['turnRatePercentList_63'] = {}
	magicList['speedPercentList_64'] = {}
	magicList['channelTimeList_65'] = {}
	magicList['stageDurationList_66'] = {}
	magicList['debuffSpeedPercentList_67'] = {}
	magicList['bounsDamagePercentageList_68'] = {}
	magicList['debuffDurationList_69'] = {}
	magicList['aoeRadiusList_70'] = {}
	magicList['damageByDistanceList_71'] = {}
	magicList['diffuseSpeedList_72'] = {}
	magicList['catchRadiusList_75'] = {}
	magicList['windSpeedList_76'] = {}
	magicList['windDamagePercentList_77'] = {}
	magicList['boundsDamagePercentList_78'] = {}
	magicList['windSpeedList_79'] = {}
	magicList['boundsDamageList_80'] = {}
	magicList['boundsDamageCountList_81'] = {}
	magicList['shootCountList_82'] = {}
	magicList['GSpeedList_83'] = {}

	
	--local flag = false
	for key, value in pairs(magicTempList) do
		--print("GetAbilityKV-----: ", key, value)

		local tempMagicLv = 'null'
		local tempMagicName = 'null'
		local tempAbilityCooldown = 'null'
		local tempAbilityManaCost = 'null'
		local tempIconSrc = 'null'
		local tempPreMagic = 'null'
		local tempStageAbility = 'null'
		local tempUnitType = 'null'

		local speed_01 = 'null'
		local speed_02 = 'null'
		local speed_14 = 'null'
		local maxDistance_03 = 'null'
		local aoeRadius_04 = 'null'
		local aoeRadius_05 = 'null'
		local maxDistance_06 = 'null'
		local maxDistance_15 = 'null'
		local damage_07 = 'null'
		local damage_08 = 'null'
		local damage_09 = 'null'
		local maxCharges_10 = 'null'
		local chargeReplenishTime_11 = 'null'
		local energy_12 = 'null'
		local energy_13 = 'null'
		local debuffDuration_21 = 'null'
		local beatBackDistance_22 = 'null'
		local debuffDuration_23 = 'null'
		local aoeDuration_24 = 'null'
		local debuffDuration_25 = 'null'
		local debuffDuration_26 = 'null'
		local stunDebuffDuration_27 = 'null'
		local sleepDebuffDuration_28 = 'null'
		local aoeDuration_29 = 'null'
		local debuffDuration_30 = 'null'
		local aoeDuration_31 = 'null'
		local debuffDuration_32 = 'null'
		local debuffDuration_33 = 'null'
		local debuffDuration_34 = 'null'
		local aoeDuration_35 = 'null'
		local debuffDuration_36 = 'null'
		local GSpeed_37 = 'null'
		local aoeDuration_38 = 'null'
		local boomDelay_50 = 'null'
		local visionRadius_51 = 'null'
		local aoeDuration_52 = 'null'
		local debuffDuration_53 = 'null'
		local aoeDuration_54 = 'null'
		local visionTime_55 = 'null'
		local debuffDelay_56 = 'null'
		local debuffDuration_57 = 'null'
		local searchRange_58 = 'null'
		local doubleDamagePercentage_59 = 'null'
		local bounsDamagePercentage_60 = 'null'
		local sendDelay_61 = 'null'
		local chargeTime_62 = 'null'
		local turnRatePercent_63 = 'null'
		local speedPercent_64 = 'null'
		local channelTime_65 = 'null'
		local stageDuration_66 = 'null'
		local debuffSpeedPercent_67 = 'null'
		local bounsDamagePercentage_68 = 'null'
		local debuffDuration_69 = 'null'
		local aoeRadius_70 = 'null'
		local damageByDistance_71 = 'null'
		local diffuseSpeed_72 = 'null'
		local catchRadius_75 = 'null'
		local windSpeed_76 = 'null'
		local windDamagePercent_77 = 'null'
		local boundsDamagePercent_78 = 'null'
		local windSpeed_79 = 'null'
		local boundsDamage_80 = 'null'
		local boundsDamageCount_81 = 'null'
		local shootCount_82 = 'null'
		local GSpeed_83 = 'null'

		local c = 0
		for k,v in pairs(value) do

			if k == "AbilityLevel" then			
				tempMagicLv = v
				tempMagicName = key
				--print("idName:"..key)
				c= c+1
			end
			if k == "AbilityCooldown" then
				tempAbilityCooldown = v
				c = c + 1
			end
			if k == "AbilityManaCost" then
				tempAbilityManaCost = v
				c = c + 1
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
								speed_01 = j_val
							end
						end
					end
					if x == "02" then
						for i,j_val in pairs(y_table) do
							if i == 'speed' then
								speed_02 = j_val
							end
						end
					end
					if x == "14" then
						for i,j_val in pairs(y_table) do
							if i == 'speed' then
								speed_14 = j_val
							end
						end
					end
					if x == "03" then
						for i,j_val in pairs(y_table) do
							if i == 'max_distance' then
								maxDistance_03 = j_val
							end
						end
					end
					if x == "04" then
						for i,j_val in pairs(y_table) do
							if i == 'aoe_radius' then
								aoeRadius_04 = j_val
							end
						end
					end
					if x == "05" then
						for i,j_val in pairs(y_table) do
							if i == 'aoe_radius' then
								aoeRadius_05 = j_val
							end
						end
					end
					if x == "06" then
						for i,j_val in pairs(y_table) do
							if i == 'max_distance' then
								maxDistance_06 = j_val
							end
						end
					end
					if x == "15" then
						for i,j_val in pairs(y_table) do
							if i == 'max_distance' then
								maxDistance_15 = j_val
							end
						end
					end
					if x == "07" then
						for i,j_val in pairs(y_table) do
							if i == 'damage' then
								damage_07 = j_val
							end
						end
					end
					if x == "08" then
						for i,j_val in pairs(y_table) do
							if i == 'damage' then
								damage_08 = j_val
							end
						end
					end
					if x == "09" then
						for i,j_val in pairs(y_table) do
							if i == 'damage' then
								damage_09 = j_val
							end
						end
					end
					if x == "10" then
						for i,j_val in pairs(y_table) do
							if i == 'max_charges' then
								maxCharges_10 = j_val
							end
						end
					end
					if x == "11" then
						for i,j_val in pairs(y_table) do
							if i == 'charge_replenish_time' then
								chargeReplenishTime_11 = j_val
							end
						end
					end
					if x == "12" then
						for i,j_val in pairs(y_table) do
							if i == 'energy' then
								energy_12 = j_val
							end
						end
					end
					if x == "13" then
						for i,j_val in pairs(y_table) do
							if i == 'energy' then
								energy_13 = j_val
							end
						end
					end
					if x == "21" then
						for i,j_val in pairs(y_table) do
							if i == 'debuff_duration' then
								debuffDuration_21 = j_val
							end
						end
					end
					if x == "22" then
						for i,j_val in pairs(y_table) do
							if i == 'beat_back_distance' then
								beatBackDistance_22 = j_val
							end
						end
					end
					if x == "23" then
						for i,j_val in pairs(y_table) do
							if i == 'debuff_duration' then
								debuffDuration_23 = j_val
							end
						end
					end
					if x == "24" then
						for i,j_val in pairs(y_table) do
							if i == 'aoe_duration' then
								aoeDuration_24 = j_val
							end
						end
					end
					if x == "25" then
						for i,j_val in pairs(y_table) do
							if i == 'debuff_duration' then
								debuffDuration_25 = string.format("%.2f", j_val)
							end
						end
					end
					if x == "26" then
						for i,j_val in pairs(y_table) do
							if i == 'debuff_duration' then
								debuffDuration_26 = j_val
							end
						end
					end
					if x == "27" then
						for i,j_val in pairs(y_table) do
							if i == 'stun_debuff_duration' then
								stunDebuffDuration_27 = j_val
							end
						end
					end
					if x == "28" then
						for i,j_val in pairs(y_table) do
							if i == 'sleep_debuff_duration' then
								sleepDebuffDuration_28 = j_val
							end
						end
					end
					if x == "29" then
						for i,j_val in pairs(y_table) do
							if i == 'aoe_duration' then
								aoeDuration_29 = j_val
							end
						end
					end
					if x == "30" then
						for i,j_val in pairs(y_table) do
							if i == 'debuff_duration' then
								debuffDuration_30 = j_val
							end
						end
					end
					if x == "31" then
						for i,j_val in pairs(y_table) do
							if i == 'aoe_duration' then
								aoeDuration_31 = j_val
							end
						end
					end
					if x == "32" then
						for i,j_val in pairs(y_table) do
							if i == 'debuff_duration' then
								debuffDuration_32 = j_val
							end
						end
					end
					if x == "33" then
						for i,j_val in pairs(y_table) do
							if i == 'debuff_duration' then
								debuffDuration_33 = j_val
							end
						end
					end
					if x == "34" then
						for i,j_val in pairs(y_table) do
							if i == 'debuff_duration' then
								debuffDuration_34 = j_val
							end
						end
					end
					if x == "35" then
						for i,j_val in pairs(y_table) do
							if i == 'aoe_duration' then
								aoeDurationz_35 = j_val
							end
						end
					end
					if x == "36" then
						for i,j_val in pairs(y_table) do
							if i == 'debuff_duration' then
								debuffDuration_36 = j_val
							end
						end
					end
					if x == "37" then
						for i,j_val in pairs(y_table) do
							if i == 'G_speed' then
								GSpeed_37 = j_val
							end
						end
					end
					if x == "38" then
						for i,j_val in pairs(y_table) do
							if i == 'aoe_duration' then
								aoeDuration_38 = string.format("%.2f", j_val)
							end
						end
					end
					
					if x == "50" then
						for i,j_val in pairs(y_table) do
							if i == 'boom_delay' then
								boomDelay_50 = string.format("%.2f", j_val)
							end
						end
					end
					if x == "51" then
						for i,j_val in pairs(y_table) do
							if i == 'vision_radius' then
								visionRadius_51 = j_val
							end
						end
					end
					if x == "52" then
						for i,j_val in pairs(y_table) do
							if i == 'aoe_duration' then
								aoeDuration_52 = j_val
							end
						end
					end
					if x == "53" then
						for i,j_val in pairs(y_table) do
							if i == 'debuff_duration' then
								debuffDuration_53 = j_val
							end
						end
					end
					if x == "54" then
						for i,j_val in pairs(y_table) do
							if i == 'aoe_duration' then
								aoeDuration_54 = j_val
							end
						end
					end
					if x == "55" then
						for i,j_val in pairs(y_table) do
							if i == 'vision_time' then					
								visionTime_55 = string.format("%.2f", j_val)
							end
						end
					end
					if x == "56" then
						for i,j_val in pairs(y_table) do
							if i == 'debuff_delay' then
								debuffDelay_56 = j_val
							end
						end
					end
					if x == "57" then
						for i,j_val in pairs(y_table) do
							if i == 'debuff_duration' then
								debuffDuration_57 = j_val
							end
						end
					end
					if x == "58" then
						for i,j_val in pairs(y_table) do
							if i == 'search_range' then
								searchRange_58 = j_val
							end
						end
					end
					if x == "59" then
						for i,j_val in pairs(y_table) do
							if i == 'double_damage_percentage' then
								doubleDamagePercentage_59 = j_val
							end
						end
					end
					if x == "60" then
						for i,j_val in pairs(y_table) do
							if i == 'bouns_damage_percentage' then
								bounsDamagePercentage_60 = j_val
							end
						end
					end
					if x == "61" then
						for i,j_val in pairs(y_table) do
							if i == 'send_delay' then
								sendDelay_61 = j_val
							end
						end
					end
					if x == "62" then
						for i,j_val in pairs(y_table) do
							if i == 'charge_time' then
								chargeTime_62 = string.format("%.2f", j_val)
							end
						end
					end
					if x == "63" then
						for i,j_val in pairs(y_table) do
							if i == 'turn_rate_percent' then
								turnRatePercent_63 = j_val
							end
						end
					end
					if x == "64" then
						for i,j_val in pairs(y_table) do
							if i == 'speed_percent' then
								speedPercent_64 = j_val
							end
						end
					end
					if x == "65" then
						for i,j_val in pairs(y_table) do
							if i == 'channel_time' then
								channelTime_65 = string.format("%.2f", j_val)
							end
						end
					end
					if x == "66" then
						for i,j_val in pairs(y_table) do
							if i == 'stage_duration' then
								stageDuration_66 = j_val
							end
						end
					end
					if x == "67" then
						for i,j_val in pairs(y_table) do
							if i == 'debuff_speed_percent' then
								debuffSpeedPercent_67 = j_val
							end
						end
					end
					if x == "68" then
						for i,j_val in pairs(y_table) do
							if i == 'bouns_damage_percentage' then
								bounsDamagePercentage_68 = j_val
							end
						end
					end
					if x == "69" then
						for i,j_val in pairs(y_table) do
							if i == 'debuff_duration' then
								debuffDuration_69 = j_val
							end
						end
					end
					if x == "70" then
						for i,j_val in pairs(y_table) do
							if i == 'aoe_radius' then
								aoeRadius_70 = j_val
							end
						end
					end
					if x == "71" then
						for i,j_val in pairs(y_table) do
							if i == 'damage_by_distance' then
								damageByDistance_71 = j_val
							end
						end
					end
					if x == "72" then
						for i,j_val in pairs(y_table) do
							if i == 'diffuse_speed' then
								diffuseSpeed_72 = j_val
							end
						end
					end
					if x == "75" then
						for i,j_val in pairs(y_table) do
							if i == 'catch_radius' then
								catchRadius_75 = string.format("%.2f", j_val)
							end
						end
					end
					if x == "76" then
						for i,j_val in pairs(y_table) do
							if i == 'wind_speed' then
								windSpeed_76 = j_val
							end
						end
					end
					if x == "77" then
						for i,j_val in pairs(y_table) do
							if i == 'wind_damage_percent' then
								windDamagePercent_77 = j_val
							end
						end
					end
					if x == "78" then
						for i,j_val in pairs(y_table) do
							if i == 'bounds_damage_percent' then
								boundsDamagePercent_78 = j_val
							end
						end
					end
					if x == "79" then
						for i,j_val in pairs(y_table) do
							if i == 'wind_speed' then
								windSpeed_79 = j_val
							end
						end
					end
					if x == "80" then
						for i,j_val in pairs(y_table) do
							if i == 'bounds_damage' then
								boundsDamage_80 = j_val
							end
						end
					end
					if x == "81" then
						for i,j_val in pairs(y_table) do
							if i == 'bounds_damage_count' then
								boundsDamageCount_81 = j_val
							end
						end
					end
					if x == "82" then
						for i,j_val in pairs(y_table) do
							if i == 'shoot_count' then
								shootCount_82 = j_val
							end
						end
					end
					if x == "83" then
						for i,j_val in pairs(y_table) do
							if i == 'G_speed' then
								GSpeed_83 = j_val
							end
						end
					end
					

				end
				c=c+1
			end

			if c == 10 then
                --print("===============idName:"..tempMagicName.."speed:"..tempSpeed)
				table.insert(magicList['magicNameList'],tempMagicName)
				table.insert(magicList['abilityCooldownList'],tempAbilityCooldown)
				table.insert(magicList['abilityManaCostList'],tempAbilityManaCost)

				table.insert(magicList['magicIconSrcList'],tempIconSrc)
				table.insert(magicList['preMagicList'],tempPreMagic)
				table.insert(magicList['magicLvList'],tempMagicLv)
				table.insert(magicList['stageAbilityList'],tempStageAbility)
				table.insert(magicList['unitTypeList'],tempUnitType)

				table.insert(magicList['speedList_01'],speed_01)
				table.insert(magicList['speedList_02'],speed_02)
				table.insert(magicList['speedList_14'],speed_14)
				table.insert(magicList['maxDistanceList_03'],maxDistance_03)
				table.insert(magicList['aoeRadiusList_04'],aoeRadius_04)
				table.insert(magicList['aoeRadiusList_05'],aoeRadius_05)
				table.insert(magicList['maxDistanceList_06'],maxDistance_06)
				table.insert(magicList['maxDistanceList_15'],maxDistance_15)
				table.insert(magicList['damageList_07'],damage_07)
				table.insert(magicList['damageList_08'],damage_08)
				table.insert(magicList['damageList_09'],damage_09)
				table.insert(magicList['maxChargesList_10'],maxCharges_10)
				table.insert(magicList['chargeReplenishTimeList_11'],chargeReplenishTime_11)
				table.insert(magicList['energyList_12'],energy_12)
				table.insert(magicList['energyList_13'],energy_13)
				table.insert(magicList['debuffDurationList_21'],debuffDuration_21)
				table.insert(magicList['beatBackDistanceList_22'],beatBackDistance_22)
				table.insert(magicList['debuffDurationList_23'],debuffDuration_23)
				table.insert(magicList['aoeDurationList_24'],aoeDuration_24)
				table.insert(magicList['debuffDurationList_25'],debuffDuration_25)
				table.insert(magicList['debuffDurationList_26'],debuffDuration_26)
				table.insert(magicList['stunDebuffDurationList_27'],stunDebuffDuration_27)
				table.insert(magicList['sleepDebuffDurationList_28'],sleepDebuffDuration_28)
				table.insert(magicList['aoeDurationList_29'],aoeDuration_29)
				table.insert(magicList['debuffDurationList_30'],debuffDuration_30)
				table.insert(magicList['aoeDurationList_31'],aoeDuration_31)
				table.insert(magicList['debuffDurationList_32'],debuffDuration_32)
				table.insert(magicList['debuffDurationList_33'],debuffDuration_33)
				table.insert(magicList['debuffDurationList_34'],debuffDuration_34)
				table.insert(magicList['aoeDurationList_35'],aoeDuration_35)
				table.insert(magicList['debuffDurationList_36'],debuffDuration_36)
				table.insert(magicList['GSpeedList_37'],GSpeed_37)
				table.insert(magicList['aoeDurationList_38'],aoeDuration_38)
				table.insert(magicList['boomDelayList_50'],boomDelay_50)
				table.insert(magicList['visionRadiusList_51'],visionRadius_51)
				table.insert(magicList['aoeDurationList_52'],aoeDuration_52)
				table.insert(magicList['debuffDurationList_53'],debuffDuration_53)
				table.insert(magicList['aoeDurationList_54'],aoeDuration_54)
				table.insert(magicList['visionTimeList_55'],visionTime_55)
				table.insert(magicList['debuffDelayList_56'],debuffDelay_56)
				table.insert(magicList['debuffDurationList_57'],debuffDuration_57)
				table.insert(magicList['searchRangeList_58'],searchRange_58)
				table.insert(magicList['doubleDamagePercentageList_59'],doubleDamagePercentage_59)
				table.insert(magicList['bounsDamagePercentageList_60'],bounsDamagePercentage_60)
				table.insert(magicList['sendDelayList_61'],sendDelay_61)
				table.insert(magicList['chargeTimeList_62'],chargeTime_62)
				table.insert(magicList['turnRatePercentList_63'],turnRatePercent_63)
				table.insert(magicList['speedPercentList_64'],speedPercent_64)
				table.insert(magicList['channelTimeList_65'],channelTime_65)
				table.insert(magicList['stageDurationList_66'],stageDuration_66)
				table.insert(magicList['debuffSpeedPercentList_67'],debuffSpeedPercent_67)
				table.insert(magicList['bounsDamagePercentageList_68'],bounsDamagePercentage_68)
				table.insert(magicList['debuffDurationList_69'],debuffDuration_69)
				table.insert(magicList['aoeRadiusList_70'],aoeRadius_70)
				table.insert(magicList['damageByDistanceList_71'],damageByDistance_71)
				table.insert(magicList['diffuseSpeedList_72'],diffuseSpeed_72)
				table.insert(magicList['catchRadiusList_75'],catchRadius_75)
				table.insert(magicList['windSpeedList_76'],windSpeed_76)
				table.insert(magicList['windDamagePercentList_77'],windDamagePercent_77)
				table.insert(magicList['boundsDamagePercentList_78'],boundsDamagePercent_78)
				table.insert(magicList['windSpeedList_79'],windSpeed_79)
				table.insert(magicList['boundsDamageList_80'],boundsDamage_80)
				table.insert(magicList['boundsDamageCountList_81'],boundsDamageCount_81)
				table.insert(magicList['shootCountList_82'],shootCount_82)
				table.insert(magicList['GSpeedList_83'],GSpeed_83)
				break
			end
		end
	end
    --print("listOVER",#magicNameList)
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
	--5-7回合
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

		local stageModifiersName = "modifier_counter_"..tempStageMagic
		if hHero:HasModifier(stageModifiersName) then
			hHero:RemoveModifierByName(stageModifiersName)
		end
		hHero:AddAbility(stageAbility)	
		--hHero:FindAbilityByName(stageAbility):SetLevel(1)
	end
	local tempMagic = hHero:GetAbilityByIndex(abilityIndex):GetAbilityName()
	hHero:RemoveAbility(tempMagic)
	local modifiersName = "modifier_counter_"..tempMagic
	--print("modifierCounter=============="..modifiersName)
	if hHero:HasModifier(modifiersName) then
		hHero:RemoveModifierByName(modifiersName)
	end
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


	local rebuildNameList = {}
	local rebuildIconList = {}


	for i = 1 , #magicList['magicNameList'] do
		local listNum = 0
		if magicList['magicNameList'][i] == magic_c then
			listNum = 1
		end
		if magicList['magicNameList'][i] == magic_b then
			listNum = 2
		end
		if magicList['magicNameList'][i] == magic_a then
			listNum = 3
		end

		if listNum ~= 0 then
			rebuildNameList[listNum] = magicList['magicNameList'][i]
			rebuildIconList[listNum] = magicList['magicIconSrcList'][i]
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

function closeMagicListTimeUp()
	for playerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
        if PlayerResource:GetConnectionState(playerID) == DOTA_CONNECTION_STATE_CONNECTED then
			if playerRoundLearn[playerID] == 0 then
				closeUIMagicList(playerID)
			end
		end
	end
end