require('myMaths')
require('game_init')
function openUIMagicList( playerID )
	CustomUI:DynamicHud_Create(playerID,"UIMagicListPanelBox","file://{resources}/layout/custom_game/UI_magic_list.xml",nil)
end

function closeUIMagicList(playerID)
    CustomUI:DynamicHud_Destroy(playerID,"UIMagicListPanelBox")
end

function getMagicListFunc(playerID,MagicLevel,preMagic,listCount,functionForLUATOJS)

	--print("magicList:"..#magicList)
	local magicListByCondition = {}
	for i = 1, #magicList, 1 do
		if magicList[i]['magicLvList'] == MagicLevel and  magicList[i]['preMagicList'] == preMagic then
			--print("lv:"..magicList[i]['magicLvList'])
			--print("name:"..magicList[i]['magicNameList'])
			table.insert(magicListByCondition,magicList[i])
		end
	end
	--print("magicListByCondition:"..#magicListByCondition)

	--print("MagicLevel:",MagicLevel,"preMagic:",preMagic,"==")


	--随机数字数组
	local randomNumList = getRandomNumList(1,#magicListByCondition,listCount)
	--根据随机数字数组得出随机技能详细数组
	local randomMagicList = getRandomArrayList(magicListByCondition, randomNumList)
	
	RandomMagicNameList[playerID] = randomMagicList--randomNameList

	local listLength = #randomMagicList--#randomNameList

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
	--print("randomMagicList:"..#randomMagicList)
	--print(randomMagicList[1]['magicNameList'])
	CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(playerID), functionForLUATOJS, {
        listLength=listLength, 
		titleValue = titleValue,
		randomMagicList = randomMagicList
		
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
	local preMagic = hHero:GetAbilityByIndex(0):GetAbilityName()
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
	local preMagic = hHero:GetAbilityByIndex(0):GetAbilityName()
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
	local preMagic = hHero:GetAbilityByIndex(1):GetAbilityName()
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
	local preMagic = hHero:GetAbilityByIndex(2):GetAbilityName()
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
	
	--local flag = false
	local icount = 1
	
	for key, value in pairs(magicTempList) do
		--print("GetAbilityKV-----: ", key, value)

		local tempMagicName = 'null'
		
		local tempAbilityCooldown = 'null'
		local tempAbilityManaCost = 'null'
		local tempPreMagic = 'null'
		local tempStageAbility = 'null'
		local tempUnitType = 'null'
		local tempAbilityLevel = 'null'
		local tempIconSrc = 'null'

		local unitModel = 'null'
		local hitType = 'null'
		local isAOE = 'null'
		local isMisfire = 'null'
		--local cp = 'null'
		--local particles_hit_dur = 'null'


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
		local disableTurningTime_39 = 'null'
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
				tempAbilityLevel = v
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
			if k == "unitModel" then
				unitModel = v
				c = c+1
			end
			if k == "hitType" then
				hitType = v
				c = c+1
			end
			if k == "isAOE" then
				isAOE = v
				c = c+1
			end
			if k == "isMisfire" then
				isMisfire = v
				c = c+1
			end
			--[[
			if k == "cp" then
				cp = v
				c = c+1
			end
			if k == "particles_hit_dur" then
				particles_hit_dur = v
				c = c+1
			end]]

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
								debuffDuration_25 =  j_val
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
								aoeDuration_38 = j_val
							end
						end
					end
					if x == "39" then
						for i,j_val in pairs(y_table) do
							if i == 'disable_turning_time' then
								disableTurningTime_39 = j_val
							end
						end
					end
					
					if x == "50" then
						for i,j_val in pairs(y_table) do
							if i == 'boom_delay' then
								boomDelay_50 =  j_val
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
								visionTime_55 =  j_val
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
								chargeTime_62 = j_val
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
								channelTime_65 =  j_val
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
								catchRadius_75 = j_val
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
			--print("=======cc========"..c)
			if c == 12 then
                --print("===============idName:"..tempMagicName.."speed:"..tempSpeed)
				magicList[icount] = {}
				magicList[icount]['magicNameList'] = tempMagicName
				magicList[icount]['abilityCooldownList'] = tempAbilityCooldown
				magicList[icount]['abilityManaCostList'] = tempAbilityManaCost
				magicList[icount]['magicIconSrcList'] = tempIconSrc
				magicList[icount]['preMagicList'] = tempPreMagic
				magicList[icount]['magicLvList'] = tempAbilityLevel
				magicList[icount]['stageAbilityList'] = tempStageAbility
				magicList[icount]['unitTypeList'] = tempUnitType

				magicList[icount]['unitModel'] = unitModel
				magicList[icount]['hitType'] = hitType
				magicList[icount]['isAOE'] = isAOE
				magicList[icount]['isMisfire'] = isMisfire
				--magicList[icount]['cp'] = cp
				--magicList[icount]['particles_hit_dur'] = particles_hit_dur

				magicList[icount]['speedList_01'] = speed_01
				magicList[icount]['speedList_02'] = speed_02
				magicList[icount]['speedList_14'] = speed_14
				magicList[icount]['maxDistanceList_03'] = maxDistance_03
				magicList[icount]['aoeRadiusList_04'] = aoeRadius_04
				magicList[icount]['aoeRadiusList_05'] = aoeRadius_05
				magicList[icount]['maxDistanceList_06'] = maxDistance_06
				magicList[icount]['maxDistanceList_15'] = maxDistance_15
				magicList[icount]['damageList_07'] = damage_07
				magicList[icount]['damageList_08'] = damage_08
				magicList[icount]['damageList_09'] = damage_09
				magicList[icount]['maxChargesList_10'] = maxCharges_10
				magicList[icount]['chargeReplenishTimeList_11'] = chargeReplenishTime_11
				magicList[icount]['energyList_12'] = energy_12
				magicList[icount]['energyList_13'] = energy_13
				magicList[icount]['debuffDurationList_21'] = debuffDuration_21
				magicList[icount]['beatBackDistanceList_22'] = beatBackDistance_22
				magicList[icount]['debuffDurationList_23'] = debuffDuration_23
				magicList[icount]['aoeDurationList_24'] = aoeDuration_24
				magicList[icount]['debuffDurationList_25'] = debuffDuration_25
				magicList[icount]['debuffDurationList_26'] = debuffDuration_26
				magicList[icount]['stunDebuffDurationList_27'] = stunDebuffDuration_27
				magicList[icount]['sleepDebuffDurationList_28'] = sleepDebuffDuration_28
				magicList[icount]['aoeDurationList_29'] = aoeDuration_29
				magicList[icount]['debuffDurationList_30'] = debuffDuration_30
				magicList[icount]['aoeDurationList_31'] = aoeDuration_31
				magicList[icount]['debuffDurationList_32'] = debuffDuration_32
				magicList[icount]['debuffDurationList_33'] = debuffDuration_33
				magicList[icount]['debuffDurationList_34'] = debuffDuration_34
				magicList[icount]['aoeDurationList_35'] = aoeDuration_35
				magicList[icount]['debuffDurationList_36'] = debuffDuration_36
				magicList[icount]['GSpeedList_37'] = GSpeed_37
				magicList[icount]['aoeDurationList_38'] = aoeDuration_38
				magicList[icount]['disableTurningTimeList_39'] = disableTurningTime_39
				magicList[icount]['boomDelayList_50'] = boomDelay_50
				magicList[icount]['visionRadiusList_51'] = visionRadius_51
				magicList[icount]['aoeDurationList_52'] = aoeDuration_52
				magicList[icount]['debuffDurationList_53'] = debuffDuration_53
				magicList[icount]['aoeDurationList_54'] = aoeDuration_54
				magicList[icount]['visionTimeList_55'] = visionTime_55
				magicList[icount]['debuffDelayList_56'] = debuffDelay_56
				magicList[icount]['debuffDurationList_57'] = debuffDuration_57
				magicList[icount]['searchRangeList_58'] = searchRange_58
				magicList[icount]['doubleDamagePercentageList_59'] = doubleDamagePercentage_59
				magicList[icount]['bounsDamagePercentageList_60'] = bounsDamagePercentage_60
				magicList[icount]['sendDelayList_61'] = sendDelay_61
				magicList[icount]['chargeTimeList_62'] = chargeTime_62
				magicList[icount]['turnRatePercentList_63'] = turnRatePercent_63
				magicList[icount]['speedPercentList_64'] = speedPercent_64
				magicList[icount]['channelTimeList_65'] = channelTime_65
				magicList[icount]['stageDurationList_66'] = stageDuration_66
				magicList[icount]['debuffSpeedPercentList_67'] = debuffSpeedPercent_67
				magicList[icount]['bounsDamagePercentageList_68'] = bounsDamagePercentage_68
				magicList[icount]['debuffDurationList_69'] = debuffDuration_69
				magicList[icount]['aoeRadiusList_70'] = aoeRadius_70
				magicList[icount]['damageByDistanceList_71'] = damageByDistance_71
				magicList[icount]['diffuseSpeedList_72'] = diffuseSpeed_72
				magicList[icount]['catchRadiusList_75'] = catchRadius_75
				magicList[icount]['windSpeedList_76'] = windSpeed_76
				magicList[icount]['windDamagePercentList_77'] = windDamagePercent_77
				magicList[icount]['boundsDamagePercentList_78'] = boundsDamagePercent_78
				magicList[icount]['windSpeedList_79'] = windSpeed_79
				magicList[icount]['boundsDamageList_80'] = boundsDamage_80
				magicList[icount]['boundsDamageCountList_81'] = boundsDamageCount_81
				magicList[icount]['shootCountList_82'] = shootCount_82
				magicList[icount]['GSpeedList_83'] = GSpeed_83
				icount = icount + 1
				--print("magicList++:"..tempMagicName)
				break
			end
		end
	end

	magicListByName = {}

	for i = 1, #magicList ,1 do
		local magicName = magicList[i]['magicNameList']
		magicListByName[magicName] = {}
		magicListByName[magicName] = magicList[i]
	end
	--print("magicListByName:"..#magicList)
	--print("magicListByName:"..#magicListByName)
	--[[
	for key, value in pairs(magicListByName) do
		print("===magicListByName===")
		print(key)
		print(value['magicNameList'])
	end]]
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
        if PlayerResource:GetConnectionState(playerID) ~= DOTA_CONNECTION_STATE_UNKNOWN then
			if playerRoundLearn[playerID] == 0 or playerRoundLearn[playerID] == nil then
				learnMagicByNum(playerID, learnNum)
			end
		end
	end
end

function learnMagicByNum(playerID, num)
	local player = PlayerResource:GetPlayer(playerID)
    local hHero = PlayerResource:GetSelectedHeroEntity(playerID)

    local magicName = RandomMagicNameList[playerID][num]['magicNameList']
	--local magicNameAllList = magicList['magicNameList']
	--local preMagicList = GameRules.preMagicList
	--local magicLvList = magicList['magicLvList']
	--local stageAbilityList = magicList['stageAbilityList']
	local magicLv
	local stageAbility
	local abilityIndex
	for i = 1 , #magicList do
		if magicName == magicList[i]['magicNameList'] then
			magicLv = magicList[i]['magicLvList']
			stageAbility = magicList[i]['stageAbilityList']
		end
	end

	if magicLv == 'c' then
		abilityIndex = 0
		stageAbilityIndex = 6
	end
	if magicLv== 'b' then
		abilityIndex = 1
		stageAbilityIndex = 7
	end
	if magicLv == 'a' then
		abilityIndex = 2
		stageAbilityIndex = 8
	end

	if stageAbility ~= 'null' then
		local tempStageMagic = hHero:GetAbilityByIndex(stageAbilityIndex):GetAbilityName()
		--print("tempStageMagic",tempStageMagic)
		--print("stageAbility",stageAbility)
		hHero:RemoveAbility(tempStageMagic) 

		--local stageModifiersName = "modifier_counter_"..tempStageMagic
		--if hHero:HasModifier(stageModifiersName) then
		--	hHero:RemoveModifierByName(stageModifiersName)
		--end
		hHero:AddAbility(stageAbility)	
		--hHero:FindAbilityByName(stageAbility):SetLevel(1)
	end
	local tempMagic = hHero:GetAbilityByIndex(abilityIndex):GetAbilityName()
	hHero:RemoveAbility(tempMagic)
	--升级不在用这个counter计数
	--local modifiersName = "modifier_counter_"..tempMagic
	--print("modifierCounter=============="..modifiersName)
	--if hHero:HasModifier(modifiersName) then
		--hHero:RemoveModifierByName(modifiersName)
	--end
	hHero:AddAbility(magicName)
	hHero:FindAbilityByName(magicName):SetLevel(1)

	--标记已经学习技能
	playerRoundLearn[playerID] = 1
    closeUIMagicList(playerID)
	heroStudyFinish(playerID)
end


--获取可遗忘法术列表
function getRebuildMagicList(playerID)
	local hHero = PlayerResource:GetSelectedHeroEntity(playerID)

	local magic_c = hHero:GetAbilityByIndex(0):GetAbilityName()
	local magic_b = hHero:GetAbilityByIndex(1):GetAbilityName()
	local magic_a = hHero:GetAbilityByIndex(2):GetAbilityName()

	local rebuildNameList = {}
	local rebuildIconList = {}

	for i = 1 , #magicList, 1 do
		local listNum = 0
		if magicList[i]['magicNameList'] == magic_c then
			listNum = 1
		end
		if magicList[i]['magicNameList'] == magic_b then
			listNum = 2
		end
		if magicList[i]['magicNameList'] == magic_a then
			listNum = 3
		end

		if listNum ~= 0 then
			rebuildNameList[listNum] = magicList[i]['magicNameList']
			rebuildIconList[listNum] = magicList[i]['magicIconSrcList']
		end
	end
	local listLength = #rebuildNameList
	--print("===getRebuildMagicList====")
	--DeepPrintTable(rebuildNameList)
	--DeepPrintTable(rebuildIconList)
	CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(playerID), "getRebuildMagicListToForgetLUATOJS", {
		listLength=listLength, 
        magicNameList = rebuildNameList,
        magicIconSrcList = rebuildIconList
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
	local magicName = RandomMagicNameList[playerID][num]['magicNameList']
	local preMagic = magicName
	--local magicNameAllList = magicList['magicNameList']
	--local preMagicList = GameRules.preMagicList 
	--local magicLvList = magicList['magicLvList']
	local MagicLevel
	for i = 1, #magicList do
		if magicList[i]['magicNameList'] == magicName then
			MagicLevel = magicList[i]['magicLvList']
		end
	end

	closeUIMagicList(playerID)
	openUIMagicList( playerID )
	getRandomMagicList(playerID,MagicLevel,preMagic,3)

end

function closeMagicListTimeUp()
	for playerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
        if PlayerResource:GetConnectionState(playerID) ~= DOTA_CONNECTION_STATE_UNKNOWN then
			if playerRoundLearn[playerID] == 0 then
				closeUIMagicList(playerID)
			end
		end
	end
end