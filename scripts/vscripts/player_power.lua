--永久类modifier，天赋与装备专用
function setPlayerBuffByNameAndBValue(keys,buffName,baseValue)
    print("setPlayerBuffByNameAndBValue",buffName,"=",baseValue)
    local hero = keys.caster
    local playerID = hero:GetPlayerID()
    local modifierName = "player_"..buffName
    local abilityName = "ability_"..buffName.."_control"
    local modifierNameBuff = "modifier_"..buffName.."_buff"  
    local modifierNameDebuff = "modifier_"..buffName.."_debuff"
    local modifierNameFlag =  PlayerPower[playerID]["player_"..buffName.."_flag"]
    local modifierStackCount =  getPlayerPowerValueByName(hero, modifierName, baseValue)

    local modifierNameAdd
    local modifierNameRemove
    --print("setPlayerBuffByAbilityAndModifier",abilityName)
    --print(modifierNameBuff,"==",modifierNameDebuff)
    --print("HasModifier")
    --print(hero:HasModifier(modifierNameAdd))  
    print("modifierNameCount=",modifierStackCount)

    removePlayerBuffByAbilityAndModifier(hero, abilityName, modifierNameBuff,modifierNameDebuff)
   
    if ( modifierStackCount > 0 and modifierNameFlag == 1 or modifierStackCount < 0 ) then --增幅且没被禁止，或减幅
        if (modifierStackCount > 0) then   
            modifierNameAdd = modifierNameBuff
            modifierNameRemove = modifierNameDebuff
        else
            modifierNameAdd = modifierNameDebuff
            modifierNameRemove = modifierNameBuff
            modifierStackCount = modifierStackCount * -1
        end
        --print("modifierNameAdd",modifierNameAdd)
        hero:AddAbility(abilityName):SetLevel(1)
        hero:RemoveModifierByName(modifierNameRemove)
        hero:SetModifierStackCount(modifierNameAdd, hero, modifierStackCount)
        hero:RemoveAbility(abilityName)

    --卡bug过关(OnDestory层数减少时，需要再执行一次，否则不能正常运作)
        hero:AddAbility(abilityName):SetLevel(1)
        hero:RemoveModifierByName(modifierNameRemove)
        hero:SetModifierStackCount(modifierNameAdd, hero, modifierStackCount)
        hero:RemoveAbility(abilityName)
    end
  
end


--条件触发，有持续时间的modifier
function setPlayerDurationBuffByName(keys,buffName,baseValue)
    local caster = keys.caster
    local playerID = caster:GetPlayerID()

    local modifierNameFlag =  PlayerPower[playerID]["player_"..buffName.."_flag"]    
    --print("setPlayerDurationBuffByName",buffName)
    if (PlayerPower[playerID]['player_'..buffName..'_duration'] > 0) then --（目前不计算正只计算负）
        local modifierName = "duration_"..buffName
        local abilityName = "ability_"..buffName.."_control_duration"
        local modifierNameBuff = "modifier_"..buffName.."_buff_duration"  
        local modifierNameDebuff = "modifier_"..buffName.."_debuff_duration" 
        local modifierStackCount =  getPlayerPowerValueByName(caster, modifierName, baseValue)

        --print("initPlayerDurationBuff",abilityName)
        removePlayerBuffByAbilityAndModifier(caster, abilityName, modifierNameBuff, modifierNameDebuff)
        if (modifierStackCount > 0 and modifierNameFlag == 1 or modifierStackCount < 0) then --增幅且没被禁止，或减幅
            caster:AddAbility(abilityName):SetLevel(1)
        end
    end
end


--条件触发，有持续时间的modifier
function setPlayerDurationBuffByAbilityAndModifier(keys, buffName, baseValue)
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    local modifierName = "duration_"..buffName
    local abilityName = "ability_"..buffName.."_control_duration"
    local modifierNameBuff = "modifier_"..buffName.."_buff_duration"  
    local modifierNameDebuff = "modifier_"..buffName.."_debuff_duration"
    
    local modifierStackCount =  getPlayerPowerValueByName(caster, modifierName, baseValue)
    local modifierDuration = PlayerPower[playerID]['player_'..buffName..'_duration']
    
    local modifierNameAdd
    local modifierNameRemove

    if (modifierStackCount > 0) then   
        modifierNameAdd = modifierNameBuff
        modifierNameRemove = modifierNameDebuff
    else
        modifierNameAdd = modifierNameDebuff
        modifierNameRemove = modifierNameBuff
        modifierStackCount = modifierStackCount * -1
    end
    print("setPlayerDurationBuffByAbilityAndModifier",modifierNameAdd,"==",modifierStackCount)
    print("=======================================")

    caster:RemoveModifierByName(modifierNameRemove)
    ability:ApplyDataDrivenModifier( caster, caster, modifierNameAdd, {duration = modifierDuration} )
    caster:SetModifierStackCount(modifierNameAdd, caster, modifierStackCount)

    if (caster:HasAbility(abilityName)) then
        caster:RemoveAbility(abilityName)
    end
end


function removePlayerBuffByAbilityAndModifier(hero, abilityName, modifierNameBuff,modifierNameDebuff)
    print("removePlayerBuffByAbilityAndModifier")
    --print(abilityName..modifierNameBuff..modifierNameDebuff)
    if (hero:HasAbility(abilityName)) then
        hero:RemoveAbility(abilityName)
    end
    if(hero:HasModifier(modifierNameBuff)) then
        hero:RemoveModifierByName(modifierNameBuff)
    end
    if(hero:HasModifier(modifierNameDebuff)) then
        hero:RemoveModifierByName(modifierNameDebuff)
    end
end

function setPlayerPower(playerID, powerName, isAdd, value)
    print("setPlayerPower",playerID)
    if( not isAdd ) then
        value = value * -1
    end
    print(powerName.."=="..value)
    PlayerPower[playerID][powerName] = PlayerPower[playerID][powerName] + value
    --print("PlayerPower=="..PlayerPower[playerID][powerName])
end

function setPlayerPowerFlag(playerID, powerName, value)
    print("setPlayerPowerFlag")
    PlayerPower[playerID][powerName] = value
end

--获取Modifiers层数值
function getPlayerPowerValueByName(hero, powerName, playerBaseValue)
    --local caster = keys.caster
    local playerID = hero:GetPlayerID()
    --print("getPlayerPowerValueByName",playerID,powerName,playerBaseValue)
    local precentBaseBuff = powerName .. "_precent_base"
    local precentFinalBuff = powerName .. "_precent_final"


    local powerValue = PlayerPower[playerID][powerName]
    local precentBaseValue = PlayerPower[playerID][precentBaseBuff] / 100
    local precentFinalValue = PlayerPower[playerID][precentFinalBuff] /100
    --print(powerValue,precentBaseValue,precentFinalValue)

    local stackCount = (playerBaseValue * (1 + precentBaseValue) + powerValue ) * (1 + precentFinalValue) - playerBaseValue
    --print(powerName,"=stackCount=",stackCount)

    return stackCount
end

--能力数值运算，获取装备与辅助buff的计算值
function getFinalValueOperation(playerID,baseValue,buffName,abilityLevel,owner)
	local abilityBuffName = buffName.."_"..abilityLevel
	--print("getFinalValueOperation"..playerID..abilityBuffName)
	local precentBase = PlayerPower[playerID]['player_'..abilityBuffName..'_precent_base'] / 100
	local bonusValue = PlayerPower[playerID]['player_'..abilityBuffName]
	local precentFinal = PlayerPower[playerID]['player_'..abilityBuffName..'_precent_final'] / 100
	local tempPrecentBase = PlayerPower[playerID]['temp_'..abilityBuffName..'_precent_base'] / 100
	local tempBonusValue = PlayerPower[playerID]['temp_'..abilityBuffName]
	local tempPrecentFinal = PlayerPower[playerID]['temp_'..abilityBuffName..'_precent_final'] / 100
	--临时带持续时间的加强的功能还没做
	local durationPrecentBase = 0
	local durationBonusValue = 0
	local durationPrecentFinal = 0 
	--print("getFinalValueOperation")
	--print(precentBase..","..bonusValue..","..precentFinal)
	--print(tempPrecentBase..","..tempBonusValue..","..tempPrecentFinal)
	local flag = PlayerPower[playerID]['player_'..buffName..'_flag']
	local returnValue = 0
	local operationValue =  (baseValue * (1 + precentBase + tempPrecentBase + durationPrecentBase) + bonusValue + tempBonusValue + durationBonusValue) * (1 + precentFinal + tempPrecentFinal + durationPrecentFinal)
	if (flag == 1) then
		returnValue = operationValue
	end
	if( flag == 0 and returnValue <= baseValue)then
		returnValue = operationValue
	end
	if (flag == 0 and returnValue > baseValue) then
		returnValue = baseValue
	end
	--print("flag:"..flag..",baseValue:"..baseValue..",returnValue"..returnValue)
	return returnValue
end

--基础属性数据包
function initPlayerPower()
    PlayerPower={}

    for playerID = 0, 9 do --10个玩家的数据包
        PlayerPower[playerID] = {} 

        --用于记录正负电击的两个电极子弹
        PlayerPower[playerID]["electric_shock_a"] = nil
        PlayerPower[playerID]["electric_shock_b"] = nil
        --Modifiers能力
        PlayerPower[playerID]['player_vision'] = 0
        PlayerPower[playerID]['player_vision_precent_base'] = 0
        PlayerPower[playerID]['player_vision_precent_final'] = 0
        PlayerPower[playerID]['temp_vision'] = 0
        PlayerPower[playerID]['temp_vision_precent_base'] = 0
        PlayerPower[playerID]['temp_vision_precent_final'] = 0
        PlayerPower[playerID]['duration_vision'] = 0
        PlayerPower[playerID]['duration_vision_precent_base'] = 0
        PlayerPower[playerID]['duration_vision_precent_final'] = 0
        PlayerPower[playerID]['player_vision_duration'] = 0        
        PlayerPower[playerID]['player_vision_flag'] = 1

        PlayerPower[playerID]['player_speed'] = 0
        PlayerPower[playerID]['player_speed_precent_base'] = 0
        PlayerPower[playerID]['player_speed_precent_final'] = 0
        PlayerPower[playerID]['temp_speed'] = 0
        PlayerPower[playerID]['temp_speed_precent_base'] = 0
        PlayerPower[playerID]['temp_speed_precent_final'] = 0
        PlayerPower[playerID]['duration_speed'] = 0
        PlayerPower[playerID]['duration_speed_precent_base'] = 0
        PlayerPower[playerID]['duration_speed_precent_final'] = 0
        PlayerPower[playerID]['player_speed_duration'] = 0   
        PlayerPower[playerID]['player_speed_flag'] = 1
        

        PlayerPower[playerID]['player_health'] = 0     
        PlayerPower[playerID]['player_health_precent_base'] = 0
        PlayerPower[playerID]['player_health_precent_final'] = 0
        PlayerPower[playerID]['temp_health'] = 0     
        PlayerPower[playerID]['temp_health_precent_base'] = 0
        PlayerPower[playerID]['temp_health_precent_final'] = 0
        PlayerPower[playerID]['duration_health'] = 0     
        PlayerPower[playerID]['duration_health_precent_base'] = 0
        PlayerPower[playerID]['duration_health_precent_final'] = 0
        PlayerPower[playerID]['player_health_duration'] = 0      
        PlayerPower[playerID]['player_health_flag'] = 1

        PlayerPower[playerID]['player_mana'] = 0     
        PlayerPower[playerID]['player_mana_precent_base'] = 0
        PlayerPower[playerID]['player_mana_precent_final'] = 0
        PlayerPower[playerID]['temp_mana'] = 0     
        PlayerPower[playerID]['temp_mana_precent_base'] = 0
        PlayerPower[playerID]['temp_mana_precent_final'] = 0
        PlayerPower[playerID]['duration_mana'] = 0     
        PlayerPower[playerID]['duration_mana_precent_base'] = 0
        PlayerPower[playerID]['duration_mana_precent_final'] = 0
        PlayerPower[playerID]['player_mana_duration'] = 0
        PlayerPower[playerID]['player_mana_flag'] = 1

        PlayerPower[playerID]['player_mana_regen'] = 0     
        PlayerPower[playerID]['player_mana_regen_precent_base'] = 0
        PlayerPower[playerID]['player_mana_regen_precent_final'] = 0
        PlayerPower[playerID]['temp_mana_regen'] = 0     
        PlayerPower[playerID]['temp_mana_regen_precent_base'] = 0
        PlayerPower[playerID]['temp_mana_regen_precent_final'] = 0
        PlayerPower[playerID]['duration_mana_regen'] = 0     
        PlayerPower[playerID]['duration_mana_regen_precent_base'] = 0
        PlayerPower[playerID]['duration_mana_regen_precent_final'] = 0
        PlayerPower[playerID]['player_mana_regen_duration'] = 0
        PlayerPower[playerID]['player_mana_regen_flag'] = 1

        PlayerPower[playerID]['player_defense'] = 0     
        PlayerPower[playerID]['player_defense_precent_base'] = 0
        PlayerPower[playerID]['player_defense_precent_final'] = 0
        PlayerPower[playerID]['temp_defense'] = 0     
        PlayerPower[playerID]['temp_defense_precent_base'] = 0
        PlayerPower[playerID]['temp_defense_precent_final'] = 0
        PlayerPower[playerID]['duration_defense'] = 0     
        PlayerPower[playerID]['duration_defense_precent_base'] = 0
        PlayerPower[playerID]['duration_defense_precent_final'] = 0
        PlayerPower[playerID]['player_defense_duration'] = 0
        PlayerPower[playerID]['player_defense_flag'] = 1


        --技能能力
        PlayerPower[playerID]['player_ability_speed_d'] = 0
        PlayerPower[playerID]['player_ability_speed_d_precent_base'] = 0
        PlayerPower[playerID]['player_ability_speed_d_precent_final'] = 0
        PlayerPower[playerID]['player_ability_speed_c'] = 0
        PlayerPower[playerID]['player_ability_speed_c_precent_base'] = 0
        PlayerPower[playerID]['player_ability_speed_c_precent_final'] = 0
        PlayerPower[playerID]['player_ability_speed_b'] = 0
        PlayerPower[playerID]['player_ability_speed_b_precent_base'] = 0
        PlayerPower[playerID]['player_ability_speed_b_precent_final'] = 0
        PlayerPower[playerID]['player_ability_speed_a'] = 0
        PlayerPower[playerID]['player_ability_speed_a_precent_base'] = 0
        PlayerPower[playerID]['player_ability_speed_a_precent_final'] = 0
        PlayerPower[playerID]['temp_ability_speed_d'] = 0
        PlayerPower[playerID]['temp_ability_speed_d_precent_base'] = 0
        PlayerPower[playerID]['temp_ability_speed_d_precent_final'] = 0
        PlayerPower[playerID]['temp_ability_speed_c'] = 0
        PlayerPower[playerID]['temp_ability_speed_c_precent_base'] = 0
        PlayerPower[playerID]['temp_ability_speed_c_precent_final'] = 0
        PlayerPower[playerID]['temp_ability_speed_b'] = 0
        PlayerPower[playerID]['temp_ability_speed_b_precent_base'] = 0
        PlayerPower[playerID]['temp_ability_speed_b_precent_final'] = 0
        PlayerPower[playerID]['temp_ability_speed_a'] = 0
        PlayerPower[playerID]['temp_ability_speed_a_precent_base'] = 0
        PlayerPower[playerID]['temp_ability_speed_a_precent_final'] = 0
        PlayerPower[playerID]['duration_ability_speed_d'] = 0
        PlayerPower[playerID]['duration_ability_speed_d_precent_base'] = 0
        PlayerPower[playerID]['duration_ability_speed_d_precent_final'] = 0
        PlayerPower[playerID]['duration_ability_speed_c'] = 0
        PlayerPower[playerID]['duration_ability_speed_c_precent_base'] = 0
        PlayerPower[playerID]['duration_ability_speed_c_precent_final'] = 0
        PlayerPower[playerID]['duration_ability_speed_b'] = 0
        PlayerPower[playerID]['duration_ability_speed_b_precent_base'] = 0
        PlayerPower[playerID]['duration_ability_speed_b_precent_final'] = 0
        PlayerPower[playerID]['duration_ability_speed_a'] = 0
        PlayerPower[playerID]['duration_ability_speed_a_precent_base'] = 0
        PlayerPower[playerID]['duration_ability_speed_a_precent_final'] = 0
        PlayerPower[playerID]['player_ability_speed_duration'] = 0
        PlayerPower[playerID]['player_ability_speed_flag'] = 1

        PlayerPower[playerID]['player_range_d'] = 0
        PlayerPower[playerID]['player_range_d_precent_base'] = 0
        PlayerPower[playerID]['player_range_d_precent_final'] = 0
        PlayerPower[playerID]['player_range_c'] = 0
        PlayerPower[playerID]['player_range_c_precent_base'] = 0
        PlayerPower[playerID]['player_range_c_precent_final'] = 0
        PlayerPower[playerID]['player_range_b'] = 0
        PlayerPower[playerID]['player_range_b_precent_base'] = 0
        PlayerPower[playerID]['player_range_b_precent_final'] = 0
        PlayerPower[playerID]['player_range_a'] = 0
        PlayerPower[playerID]['player_range_a_precent_base'] = 0
        PlayerPower[playerID]['player_range_a_precent_final'] = 0
        PlayerPower[playerID]['temp_range_d'] = 0
        PlayerPower[playerID]['temp_range_d_precent_base'] = 0
        PlayerPower[playerID]['temp_range_d_precent_final'] = 0
        PlayerPower[playerID]['temp_range_c'] = 0
        PlayerPower[playerID]['temp_range_c_precent_base'] = 0
        PlayerPower[playerID]['temp_range_c_precent_final'] = 0
        PlayerPower[playerID]['temp_range_b'] = 0
        PlayerPower[playerID]['temp_range_b_precent_base'] = 0
        PlayerPower[playerID]['temp_range_b_precent_final'] = 0
        PlayerPower[playerID]['temp_range_a'] = 0
        PlayerPower[playerID]['temp_range_a_precent_base'] = 0
        PlayerPower[playerID]['temp_range_a_precent_final'] = 0
        PlayerPower[playerID]['duration_range_d'] = 0
        PlayerPower[playerID]['duration_range_d_precent_base'] = 0
        PlayerPower[playerID]['duration_range_d_precent_final'] = 0
        PlayerPower[playerID]['duration_range_c'] = 0
        PlayerPower[playerID]['duration_range_c_precent_base'] = 0
        PlayerPower[playerID]['duration_range_c_precent_final'] = 0
        PlayerPower[playerID]['duration_range_b'] = 0
        PlayerPower[playerID]['duration_range_b_precent_base'] = 0
        PlayerPower[playerID]['duration_range_b_precent_final'] = 0
        PlayerPower[playerID]['duration_range_a'] = 0
        PlayerPower[playerID]['duration_range_a_precent_base'] = 0
        PlayerPower[playerID]['duration_range_a_precent_final'] = 0
        PlayerPower[playerID]['player_range_duration'] = 0
        PlayerPower[playerID]['player_range_flag'] = 1

        PlayerPower[playerID]['player_radius_d'] = 0
        PlayerPower[playerID]['player_radius_d_precent_base'] = 0
        PlayerPower[playerID]['player_radius_d_precent_final'] = 0
        PlayerPower[playerID]['player_radius_c'] = 0
        PlayerPower[playerID]['player_radius_c_precent_base'] = 0
        PlayerPower[playerID]['player_radius_c_precent_final'] = 0
        PlayerPower[playerID]['player_radius_b'] = 0
        PlayerPower[playerID]['player_radius_b_precent_base'] = 0
        PlayerPower[playerID]['player_radius_b_precent_final'] = 0
        PlayerPower[playerID]['player_radius_a'] = 0
        PlayerPower[playerID]['player_radius_a_precent_base'] = 0
        PlayerPower[playerID]['player_radius_a_precent_final'] = 0
        PlayerPower[playerID]['temp_radius_d'] = 0
        PlayerPower[playerID]['temp_radius_d_precent_base'] = 0
        PlayerPower[playerID]['temp_radius_d_precent_final'] = 0
        PlayerPower[playerID]['temp_radius_c'] = 0
        PlayerPower[playerID]['temp_radius_c_precent_base'] = 0
        PlayerPower[playerID]['temp_radius_c_precent_final'] = 0
        PlayerPower[playerID]['temp_radius_b'] = 0
        PlayerPower[playerID]['temp_radius_b_precent_base'] = 0
        PlayerPower[playerID]['temp_radius_b_precent_final'] = 0
        PlayerPower[playerID]['temp_radius_a'] = 0
        PlayerPower[playerID]['temp_radius_a_precent_base'] = 0
        PlayerPower[playerID]['temp_radius_a_precent_final'] = 0
        PlayerPower[playerID]['duration_radius_d'] = 0
        PlayerPower[playerID]['duration_radius_d_precent_base'] = 0
        PlayerPower[playerID]['duration_radius_d_precent_final'] = 0
        PlayerPower[playerID]['duration_radius_c'] = 0
        PlayerPower[playerID]['duration_radius_c_precent_base'] = 0
        PlayerPower[playerID]['duration_radius_c_precent_final'] = 0
        PlayerPower[playerID]['duration_radius_b'] = 0
        PlayerPower[playerID]['duration_radius_b_precent_base'] = 0
        PlayerPower[playerID]['duration_radius_b_precent_final'] = 0
        PlayerPower[playerID]['duration_radius_a'] = 0
        PlayerPower[playerID]['duration_radius_a_precent_base'] = 0
        PlayerPower[playerID]['duration_radius_a_precent_final'] = 0
        PlayerPower[playerID]['player_radius_duration'] = 0
        PlayerPower[playerID]['player_radius_flag'] = 1

        PlayerPower[playerID]['player_mana_cost_d'] = 0
        PlayerPower[playerID]['player_mana_cost_d_precent_base'] = 0
        PlayerPower[playerID]['player_mana_cost_d_precent_final'] = 0
        PlayerPower[playerID]['player_mana_cost_c'] = 0
        PlayerPower[playerID]['player_mana_cost_c_precent_base'] = 0
        PlayerPower[playerID]['player_mana_cost_c_precent_final'] = 0
        PlayerPower[playerID]['player_mana_cost_b'] = 0
        PlayerPower[playerID]['player_mana_cost_b_precent_base'] = 0
        PlayerPower[playerID]['player_mana_cost_b_precent_final'] = 0
        PlayerPower[playerID]['player_mana_cost_a'] = 0
        PlayerPower[playerID]['player_mana_cost_a_precent_base'] = 0
        PlayerPower[playerID]['player_mana_cost_a_precent_final'] = 0
        PlayerPower[playerID]['temp_mana_cost_d'] = 0
        PlayerPower[playerID]['temp_mana_cost_d_precent_base'] = 0
        PlayerPower[playerID]['temp_mana_cost_d_precent_final'] = 0
        PlayerPower[playerID]['temp_mana_cost_c'] = 0
        PlayerPower[playerID]['temp_mana_cost_c_precent_base'] = 0
        PlayerPower[playerID]['temp_mana_cost_c_precent_final'] = 0
        PlayerPower[playerID]['temp_mana_cost_b'] = 0
        PlayerPower[playerID]['temp_mana_cost_b_precent_base'] = 0
        PlayerPower[playerID]['temp_mana_cost_b_precent_final'] = 0
        PlayerPower[playerID]['temp_mana_cost_a'] = 0
        PlayerPower[playerID]['temp_mana_cost_a_precent_base'] = 0
        PlayerPower[playerID]['temp_mana_cost_a_precent_final'] = 0
        PlayerPower[playerID]['duration_mana_cost_d'] = 0
        PlayerPower[playerID]['duration_mana_cost_d_precent_base'] = 0
        PlayerPower[playerID]['duration_mana_cost_d_precent_final'] = 0
        PlayerPower[playerID]['duration_mana_cost_c'] = 0
        PlayerPower[playerID]['duration_mana_cost_c_precent_base'] = 0
        PlayerPower[playerID]['duration_mana_cost_c_precent_final'] = 0
        PlayerPower[playerID]['duration_mana_cost_b'] = 0
        PlayerPower[playerID]['duration_mana_cost_b_precent_base'] = 0
        PlayerPower[playerID]['duration_mana_cost_b_precent_final'] = 0
        PlayerPower[playerID]['duration_mana_cost_a'] = 0
        PlayerPower[playerID]['duration_mana_cost_a_precent_base'] = 0
        PlayerPower[playerID]['duration_mana_cost_a_precent_final'] = 0
        PlayerPower[playerID]['player_mana_cost_duration'] = 0
        PlayerPower[playerID]['player_mana_cost_flag'] = 1

        PlayerPower[playerID]['player_damage_d'] = 0
        PlayerPower[playerID]['player_damage_d_precent_base'] = 0
        PlayerPower[playerID]['player_damage_d_precent_final'] = 0
        PlayerPower[playerID]['player_damage_c'] = 0
        PlayerPower[playerID]['player_damage_c_precent_base'] = 0
        PlayerPower[playerID]['player_damage_c_precent_final'] = 0
        PlayerPower[playerID]['player_damage_b'] = 0
        PlayerPower[playerID]['player_damage_b_precent_base'] = 0
        PlayerPower[playerID]['player_damage_b_precent_final'] = 0
        PlayerPower[playerID]['player_damage_a'] = 0
        PlayerPower[playerID]['player_damage_a_precent_base'] = 0
        PlayerPower[playerID]['player_damage_a_precent_final'] = 0
        PlayerPower[playerID]['temp_damage_d'] = 0
        PlayerPower[playerID]['temp_damage_d_precent_base'] = 0
        PlayerPower[playerID]['temp_damage_d_precent_final'] = 0
        PlayerPower[playerID]['temp_damage_c'] = 0
        PlayerPower[playerID]['temp_damage_c_precent_base'] = 0
        PlayerPower[playerID]['temp_damage_c_precent_final'] = 0
        PlayerPower[playerID]['temp_damage_b'] = 0
        PlayerPower[playerID]['temp_damage_b_precent_base'] = 0
        PlayerPower[playerID]['temp_damage_b_precent_final'] = 0
        PlayerPower[playerID]['temp_damage_a'] = 0
        PlayerPower[playerID]['temp_damage_a_precent_base'] = 0
        PlayerPower[playerID]['temp_damage_a_precent_final'] = 0
        PlayerPower[playerID]['duration_damage_d'] = 0
        PlayerPower[playerID]['duration_damage_d_precent_base'] = 0
        PlayerPower[playerID]['duration_damage_d_precent_final'] = 0
        PlayerPower[playerID]['duration_damage_c'] = 0
        PlayerPower[playerID]['duration_damage_c_precent_base'] = 0
        PlayerPower[playerID]['duration_damage_c_precent_final'] = 0
        PlayerPower[playerID]['duration_damage_b'] = 0
        PlayerPower[playerID]['duration_damage_b_precent_base'] = 0
        PlayerPower[playerID]['duration_damage_b_precent_final'] = 0
        PlayerPower[playerID]['duration_damage_a'] = 0
        PlayerPower[playerID]['duration_damage_a_precent_base'] = 0
        PlayerPower[playerID]['duration_damage_a_precent_final'] = 0
        PlayerPower[playerID]['player_damage_duration'] = 0
        PlayerPower[playerID]['player_damage_flag'] = 1

        PlayerPower[playerID]['player_damage_match_d'] = 0
        PlayerPower[playerID]['player_damage_match_d_precent_base'] = 0
        PlayerPower[playerID]['player_damage_match_d_precent_final'] = 0
        PlayerPower[playerID]['player_damage_match_c'] = 0
        PlayerPower[playerID]['player_damage_match_c_precent_base'] = 0
        PlayerPower[playerID]['player_damage_match_c_precent_final'] = 0
        PlayerPower[playerID]['player_damage_match_b'] = 0
        PlayerPower[playerID]['player_damage_match_b_precent_base'] = 0
        PlayerPower[playerID]['player_damage_match_b_precent_final'] = 0
        PlayerPower[playerID]['player_damage_match_a'] = 0
        PlayerPower[playerID]['player_damage_match_a_precent_base'] = 0
        PlayerPower[playerID]['player_damage_match_a_precent_final'] = 0
        PlayerPower[playerID]['temp_damage_match_d'] = 0
        PlayerPower[playerID]['temp_damage_match_d_precent_base'] = 0
        PlayerPower[playerID]['temp_damage_match_d_precent_final'] = 0
        PlayerPower[playerID]['temp_damage_match_c'] = 0
        PlayerPower[playerID]['temp_damage_match_c_precent_base'] = 0
        PlayerPower[playerID]['temp_damage_match_c_precent_final'] = 0
        PlayerPower[playerID]['temp_damage_match_b'] = 0
        PlayerPower[playerID]['temp_damage_match_b_precent_base'] = 0
        PlayerPower[playerID]['temp_damage_match_b_precent_final'] = 0
        PlayerPower[playerID]['temp_damage_match_a'] = 0
        PlayerPower[playerID]['temp_damage_match_a_precent_base'] = 0
        PlayerPower[playerID]['temp_damage_match_a_precent_final'] = 0
        PlayerPower[playerID]['duration_damage_match_d'] = 0
        PlayerPower[playerID]['duration_damage_match_d_precent_base'] = 0
        PlayerPower[playerID]['duration_damage_match_d_precent_final'] = 0
        PlayerPower[playerID]['duration_damage_match_c'] = 0
        PlayerPower[playerID]['duration_damage_match_c_precent_base'] = 0
        PlayerPower[playerID]['duration_damage_match_c_precent_final'] = 0
        PlayerPower[playerID]['duration_damage_match_b'] = 0
        PlayerPower[playerID]['duration_damage_match_b_precent_base'] = 0
        PlayerPower[playerID]['duration_damage_match_b_precent_final'] = 0
        PlayerPower[playerID]['duration_damage_match_a'] = 0
        PlayerPower[playerID]['duration_damage_match_a_precent_base'] = 0
        PlayerPower[playerID]['duration_damage_match_a_precent_final'] = 0
        PlayerPower[playerID]['player_damage_match_duration'] = 0
        PlayerPower[playerID]['player_damage_match_flag'] = 1

        PlayerPower[playerID]['player_damage_match_helper_d'] = 0
        PlayerPower[playerID]['player_damage_match_helper_d_precent_base'] = 0
        PlayerPower[playerID]['player_damage_match_helper_d_precent_final'] = 0
        PlayerPower[playerID]['player_damage_match_helper_c'] = 0
        PlayerPower[playerID]['player_damage_match_helper_c_precent_base'] = 0
        PlayerPower[playerID]['player_damage_match_helper_c_precent_final'] = 0
        PlayerPower[playerID]['player_damage_match_helper_b'] = 0
        PlayerPower[playerID]['player_damage_match_helper_b_precent_base'] = 0
        PlayerPower[playerID]['player_damage_match_helper_b_precent_final'] = 0
        PlayerPower[playerID]['player_damage_match_helper_a'] = 0
        PlayerPower[playerID]['player_damage_match_helper_a_precent_base'] = 0
        PlayerPower[playerID]['player_damage_match_helper_a_precent_final'] = 0
        PlayerPower[playerID]['temp_damage_match_helper_d'] = 0
        PlayerPower[playerID]['temp_damage_match_helper_d_precent_base'] = 0
        PlayerPower[playerID]['temp_damage_match_helper_d_precent_final'] = 0
        PlayerPower[playerID]['temp_damage_match_helper_c'] = 0
        PlayerPower[playerID]['temp_damage_match_helper_c_precent_base'] = 0
        PlayerPower[playerID]['temp_damage_match_helper_c_precent_final'] = 0
        PlayerPower[playerID]['temp_damage_match_helper_b'] = 0
        PlayerPower[playerID]['temp_damage_match_helper_b_precent_base'] = 0
        PlayerPower[playerID]['temp_damage_match_helper_b_precent_final'] = 0
        PlayerPower[playerID]['temp_damage_match_helper_a'] = 0
        PlayerPower[playerID]['temp_damage_match_helper_a_precent_base'] = 0
        PlayerPower[playerID]['temp_damage_match_helper_a_precent_final'] = 0
        PlayerPower[playerID]['duration_damage_match_helper_d'] = 0
        PlayerPower[playerID]['duration_damage_match_helper_d_precent_base'] = 0
        PlayerPower[playerID]['duration_damage_match_helper_d_precent_final'] = 0
        PlayerPower[playerID]['duration_damage_match_helper_c'] = 0
        PlayerPower[playerID]['duration_damage_match_helper_c_precent_base'] = 0
        PlayerPower[playerID]['duration_damage_match_helper_c_precent_final'] = 0
        PlayerPower[playerID]['duration_damage_match_helper_b'] = 0
        PlayerPower[playerID]['duration_damage_match_helper_b_precent_base'] = 0
        PlayerPower[playerID]['duration_damage_match_helper_b_precent_final'] = 0
        PlayerPower[playerID]['duration_damage_match_helper_a'] = 0
        PlayerPower[playerID]['duration_damage_match_helper_a_precent_base'] = 0
        PlayerPower[playerID]['duration_damage_match_helper_a_precent_final'] = 0
        PlayerPower[playerID]['player_damage_match_helper_duration'] = 0
        PlayerPower[playerID]['player_damage_match_helper_flag'] = 1

        PlayerPower[playerID]['player_control_d'] = 0
        PlayerPower[playerID]['player_control_d_precent_base'] = 0
        PlayerPower[playerID]['player_control_d_precent_final'] = 0
        PlayerPower[playerID]['player_control_c'] = 0
        PlayerPower[playerID]['player_control_c_precent_base'] = 0
        PlayerPower[playerID]['player_control_c_precent_final'] = 0
        PlayerPower[playerID]['player_control_b'] = 0
        PlayerPower[playerID]['player_control_b_precent_base'] = 0
        PlayerPower[playerID]['player_control_b_precent_final'] = 0
        PlayerPower[playerID]['player_control_a'] = 0
        PlayerPower[playerID]['player_control_a_precent_base'] = 0
        PlayerPower[playerID]['player_control_a_precent_final'] = 0
        PlayerPower[playerID]['temp_control_d'] = 0
        PlayerPower[playerID]['temp_control_d_precent_base'] = 0
        PlayerPower[playerID]['temp_control_d_precent_final'] = 0
        PlayerPower[playerID]['temp_control_c'] = 0
        PlayerPower[playerID]['temp_control_c_precent_base'] = 0
        PlayerPower[playerID]['temp_control_c_precent_final'] = 0
        PlayerPower[playerID]['temp_control_b'] = 0
        PlayerPower[playerID]['temp_control_b_precent_base'] = 0
        PlayerPower[playerID]['temp_control_b_precent_final'] = 0
        PlayerPower[playerID]['temp_control_a'] = 0
        PlayerPower[playerID]['temp_control_a_precent_base'] = 0
        PlayerPower[playerID]['temp_control_a_precent_final'] = 0
        PlayerPower[playerID]['duration_control_d'] = 0
        PlayerPower[playerID]['duration_control_d_precent_base'] = 0
        PlayerPower[playerID]['duration_control_d_precent_final'] = 0
        PlayerPower[playerID]['duration_control_c'] = 0
        PlayerPower[playerID]['duration_control_c_precent_base'] = 0
        PlayerPower[playerID]['duration_control_c_precent_final'] = 0
        PlayerPower[playerID]['duration_control_b'] = 0
        PlayerPower[playerID]['duration_control_b_precent_base'] = 0
        PlayerPower[playerID]['duration_control_b_precent_final'] = 0
        PlayerPower[playerID]['duration_control_a'] = 0
        PlayerPower[playerID]['duration_control_a_precent_base'] = 0
        PlayerPower[playerID]['duration_control_a_precent_final'] = 0
        PlayerPower[playerID]['player_control_duration'] = 0
        PlayerPower[playerID]['player_control_flag'] = 1

        PlayerPower[playerID]['player_control_match_d'] = 0
        PlayerPower[playerID]['player_control_match_d_precent_base'] = 0
        PlayerPower[playerID]['player_control_match_d_precent_final'] = 0
        PlayerPower[playerID]['player_control_match_c'] = 0
        PlayerPower[playerID]['player_control_match_c_precent_base'] = 0
        PlayerPower[playerID]['player_control_match_c_precent_final'] = 0
        PlayerPower[playerID]['player_control_match_b'] = 0
        PlayerPower[playerID]['player_control_match_b_precent_base'] = 0
        PlayerPower[playerID]['player_control_match_b_precent_final'] = 0
        PlayerPower[playerID]['player_control_match_a'] = 0
        PlayerPower[playerID]['player_control_match_a_precent_base'] = 0
        PlayerPower[playerID]['player_control_match_a_precent_final'] = 0
        PlayerPower[playerID]['temp_control_match_d'] = 0
        PlayerPower[playerID]['temp_control_match_d_precent_base'] = 0
        PlayerPower[playerID]['temp_control_match_d_precent_final'] = 0
        PlayerPower[playerID]['temp_control_match_c'] = 0
        PlayerPower[playerID]['temp_control_match_c_precent_base'] = 0
        PlayerPower[playerID]['temp_control_match_c_precent_final'] = 0
        PlayerPower[playerID]['temp_control_match_b'] = 0
        PlayerPower[playerID]['temp_control_match_b_precent_base'] = 0
        PlayerPower[playerID]['temp_control_match_b_precent_final'] = 0
        PlayerPower[playerID]['temp_control_match_a'] = 0
        PlayerPower[playerID]['temp_control_match_a_precent_base'] = 0
        PlayerPower[playerID]['temp_control_match_a_precent_final'] = 0
        PlayerPower[playerID]['duration_control_match_d'] = 0
        PlayerPower[playerID]['duration_control_match_d_precent_base'] = 0
        PlayerPower[playerID]['duration_control_match_d_precent_final'] = 0
        PlayerPower[playerID]['duration_control_match_c'] = 0
        PlayerPower[playerID]['duration_control_match_c_precent_base'] = 0
        PlayerPower[playerID]['duration_control_match_c_precent_final'] = 0
        PlayerPower[playerID]['duration_control_match_b'] = 0
        PlayerPower[playerID]['duration_control_match_b_precent_base'] = 0
        PlayerPower[playerID]['duration_control_match_b_precent_final'] = 0
        PlayerPower[playerID]['duration_control_match_a'] = 0
        PlayerPower[playerID]['duration_control_match_a_precent_base'] = 0
        PlayerPower[playerID]['duration_control_match_a_precent_final'] = 0
        PlayerPower[playerID]['player_control_match_duration'] = 0
        PlayerPower[playerID]['player_control_match_flag'] = 1
        
        PlayerPower[playerID]['player_control_match_helper_d'] = 0
        PlayerPower[playerID]['player_control_match_helper_d_precent_base'] = 0
        PlayerPower[playerID]['player_control_match_helper_d_precent_final'] = 0
        PlayerPower[playerID]['player_control_match_helper_c'] = 0
        PlayerPower[playerID]['player_control_match_helper_c_precent_base'] = 0
        PlayerPower[playerID]['player_control_match_helper_c_precent_final'] = 0
        PlayerPower[playerID]['player_control_match_helper_b'] = 0
        PlayerPower[playerID]['player_control_match_helper_b_precent_base'] = 0
        PlayerPower[playerID]['player_control_match_helper_b_precent_final'] = 0
        PlayerPower[playerID]['player_control_match_helper_a'] = 0
        PlayerPower[playerID]['player_control_match_helper_a_precent_base'] = 0
        PlayerPower[playerID]['player_control_match_helper_a_precent_final'] = 0
        PlayerPower[playerID]['temp_control_match_helper_d'] = 0
        PlayerPower[playerID]['temp_control_match_helper_d_precent_base'] = 0
        PlayerPower[playerID]['temp_control_match_helper_d_precent_final'] = 0
        PlayerPower[playerID]['temp_control_match_helper_c'] = 0
        PlayerPower[playerID]['temp_control_match_helper_c_precent_base'] = 0
        PlayerPower[playerID]['temp_control_match_helper_c_precent_final'] = 0
        PlayerPower[playerID]['temp_control_match_helper_b'] = 0
        PlayerPower[playerID]['temp_control_match_helper_b_precent_base'] = 0
        PlayerPower[playerID]['temp_control_match_helper_b_precent_final'] = 0
        PlayerPower[playerID]['temp_control_match_helper_a'] = 0
        PlayerPower[playerID]['temp_control_match_helper_a_precent_base'] = 0
        PlayerPower[playerID]['temp_control_match_helper_a_precent_final'] = 0
        PlayerPower[playerID]['duration_control_match_helper_d'] = 0
        PlayerPower[playerID]['duration_control_match_helper_d_precent_base'] = 0
        PlayerPower[playerID]['duration_control_match_helper_d_precent_final'] = 0
        PlayerPower[playerID]['duration_control_match_helper_c'] = 0
        PlayerPower[playerID]['duration_control_match_helper_c_precent_base'] = 0
        PlayerPower[playerID]['duration_control_match_helper_c_precent_final'] = 0
        PlayerPower[playerID]['duration_control_match_helper_b'] = 0
        PlayerPower[playerID]['duration_control_match_helper_b_precent_base'] = 0
        PlayerPower[playerID]['duration_control_match_helper_b_precent_final'] = 0
        PlayerPower[playerID]['duration_control_match_helper_a'] = 0
        PlayerPower[playerID]['duration_control_match_helper_a_precent_base'] = 0
        PlayerPower[playerID]['duration_control_match_helper_a_precent_final'] = 0
        PlayerPower[playerID]['player_control_match_helper_duration'] = 0
        PlayerPower[playerID]['player_control_match_helper_flag'] = 1

        PlayerPower[playerID]['player_energy_d'] = 0
        PlayerPower[playerID]['player_energy_d_precent_base'] = 0
        PlayerPower[playerID]['player_energy_d_precent_final'] = 0
        PlayerPower[playerID]['player_energy_c'] = 0
        PlayerPower[playerID]['player_energy_c_precent_base'] = 0
        PlayerPower[playerID]['player_energy_c_precent_final'] = 0
        PlayerPower[playerID]['player_energy_b'] = 0
        PlayerPower[playerID]['player_energy_b_precent_base'] = 0
        PlayerPower[playerID]['player_energy_b_precent_final'] = 0
        PlayerPower[playerID]['player_energy_a'] = 0
        PlayerPower[playerID]['player_energy_a_precent_base'] = 0
        PlayerPower[playerID]['player_energy_a_precent_final'] = 0
        PlayerPower[playerID]['temp_energy_d'] = 0
        PlayerPower[playerID]['temp_energy_d_precent_base'] = 0
        PlayerPower[playerID]['temp_energy_d_precent_final'] = 0
        PlayerPower[playerID]['temp_energy_c'] = 0
        PlayerPower[playerID]['temp_energy_c_precent_base'] = 0
        PlayerPower[playerID]['temp_energy_c_precent_final'] = 0
        PlayerPower[playerID]['temp_energy_b'] = 0
        PlayerPower[playerID]['temp_energy_b_precent_base'] = 0
        PlayerPower[playerID]['temp_energy_b_precent_final'] = 0
        PlayerPower[playerID]['temp_energy_a'] = 0
        PlayerPower[playerID]['temp_energy_a_precent_base'] = 0
        PlayerPower[playerID]['temp_energy_a_precent_final'] = 0
        PlayerPower[playerID]['duration_energy_d'] = 0
        PlayerPower[playerID]['duration_energy_d_precent_base'] = 0
        PlayerPower[playerID]['duration_energy_d_precent_final'] = 0
        PlayerPower[playerID]['duration_energy_c'] = 0
        PlayerPower[playerID]['duration_energy_c_precent_base'] = 0
        PlayerPower[playerID]['duration_energy_c_precent_final'] = 0
        PlayerPower[playerID]['duration_energy_b'] = 0
        PlayerPower[playerID]['duration_energy_b_precent_base'] = 0
        PlayerPower[playerID]['duration_energy_b_precent_final'] = 0
        PlayerPower[playerID]['duration_energy_a'] = 0
        PlayerPower[playerID]['duration_energy_a_precent_base'] = 0
        PlayerPower[playerID]['duration_energy_a_precent_final'] = 0
        PlayerPower[playerID]['player_energy_duration'] = 0
        PlayerPower[playerID]['player_energy_flag'] = 1

        PlayerPower[playerID]['player_energy_match_d'] = 0
        PlayerPower[playerID]['player_energy_match_d_precent_base'] = 0
        PlayerPower[playerID]['player_energy_match_d_precent_final'] = 0
        PlayerPower[playerID]['player_energy_match_c'] = 0
        PlayerPower[playerID]['player_energy_match_c_precent_base'] = 0
        PlayerPower[playerID]['player_energy_match_c_precent_final'] = 0
        PlayerPower[playerID]['player_energy_match_b'] = 0
        PlayerPower[playerID]['player_energy_match_b_precent_base'] = 0
        PlayerPower[playerID]['player_energy_match_b_precent_final'] = 0
        PlayerPower[playerID]['player_energy_match_a'] = 0
        PlayerPower[playerID]['player_energy_match_a_precent_base'] = 0
        PlayerPower[playerID]['player_energy_match_a_precent_final'] = 0
        PlayerPower[playerID]['temp_energy_match_d'] = 0
        PlayerPower[playerID]['temp_energy_match_d_precent_base'] = 0
        PlayerPower[playerID]['temp_energy_match_d_precent_final'] = 0
        PlayerPower[playerID]['temp_energy_match_c'] = 0
        PlayerPower[playerID]['temp_energy_match_c_precent_base'] = 0
        PlayerPower[playerID]['temp_energy_match_c_precent_final'] = 0
        PlayerPower[playerID]['temp_energy_match_b'] = 0
        PlayerPower[playerID]['temp_energy_match_b_precent_base'] = 0
        PlayerPower[playerID]['temp_energy_match_b_precent_final'] = 0
        PlayerPower[playerID]['temp_energy_match_a'] = 0
        PlayerPower[playerID]['temp_energy_match_a_precent_base'] = 0
        PlayerPower[playerID]['temp_energy_match_a_precent_final'] = 0
        PlayerPower[playerID]['duration_energy_match_d'] = 0
        PlayerPower[playerID]['duration_energy_match_d_precent_base'] = 0
        PlayerPower[playerID]['duration_energy_match_d_precent_final'] = 0
        PlayerPower[playerID]['duration_energy_match_c'] = 0
        PlayerPower[playerID]['duration_energy_match_c_precent_base'] = 0
        PlayerPower[playerID]['duration_energy_match_c_precent_final'] = 0
        PlayerPower[playerID]['duration_energy_match_b'] = 0
        PlayerPower[playerID]['duration_energy_match_b_precent_base'] = 0
        PlayerPower[playerID]['duration_energy_match_b_precent_final'] = 0
        PlayerPower[playerID]['duration_energy_match_a'] = 0
        PlayerPower[playerID]['duration_energy_match_a_precent_base'] = 0
        PlayerPower[playerID]['duration_energy_match_a_precent_final'] = 0
        PlayerPower[playerID]['player_energy_match_duration'] = 0
        PlayerPower[playerID]['player_energy_match_flag'] = 1

        PlayerPower[playerID]['player_energy_match_helper_d'] = 0
        PlayerPower[playerID]['player_energy_match_helper_d_precent_base'] = 0
        PlayerPower[playerID]['player_energy_match_helper_d_precent_final'] = 0
        PlayerPower[playerID]['player_energy_match_helper_c'] = 0
        PlayerPower[playerID]['player_energy_match_helper_c_precent_base'] = 0
        PlayerPower[playerID]['player_energy_match_helper_c_precent_final'] = 0
        PlayerPower[playerID]['player_energy_match_helper_b'] = 0
        PlayerPower[playerID]['player_energy_match_helper_b_precent_base'] = 0
        PlayerPower[playerID]['player_energy_match_helper_b_precent_final'] = 0
        PlayerPower[playerID]['player_energy_match_helper_a'] = 0
        PlayerPower[playerID]['player_energy_match_helper_a_precent_base'] = 0
        PlayerPower[playerID]['player_energy_match_helper_a_precent_final'] = 0
        PlayerPower[playerID]['temp_energy_match_helper_d'] = 0
        PlayerPower[playerID]['temp_energy_match_helper_d_precent_base'] = 0
        PlayerPower[playerID]['temp_energy_match_helper_d_precent_final'] = 0
        PlayerPower[playerID]['temp_energy_match_helper_c'] = 0
        PlayerPower[playerID]['temp_energy_match_helper_c_precent_base'] = 0
        PlayerPower[playerID]['temp_energy_match_helper_c_precent_final'] = 0
        PlayerPower[playerID]['temp_energy_match_helper_b'] = 0
        PlayerPower[playerID]['temp_energy_match_helper_b_precent_base'] = 0
        PlayerPower[playerID]['temp_energy_match_helper_b_precent_final'] = 0
        PlayerPower[playerID]['temp_energy_match_helper_a'] = 0
        PlayerPower[playerID]['temp_energy_match_helper_a_precent_base'] = 0
        PlayerPower[playerID]['temp_energy_match_helper_a_precent_final'] = 0
        PlayerPower[playerID]['duration_energy_match_helper_d'] = 0
        PlayerPower[playerID]['duration_energy_match_helper_d_precent_base'] = 0
        PlayerPower[playerID]['duration_energy_match_helper_d_precent_final'] = 0
        PlayerPower[playerID]['duration_energy_match_helper_c'] = 0
        PlayerPower[playerID]['duration_energy_match_helper_c_precent_base'] = 0
        PlayerPower[playerID]['duration_energy_match_helper_c_precent_final'] = 0
        PlayerPower[playerID]['duration_energy_match_helper_b'] = 0
        PlayerPower[playerID]['duration_energy_match_helper_b_precent_base'] = 0
        PlayerPower[playerID]['duration_energy_match_helper_b_precent_final'] = 0
        PlayerPower[playerID]['duration_energy_match_helper_a'] = 0
        PlayerPower[playerID]['duration_energy_match_helper_a_precent_base'] = 0
        PlayerPower[playerID]['duration_energy_match_helper_a_precent_final'] = 0
        PlayerPower[playerID]['player_energy_match_helper_duration'] = 0
        PlayerPower[playerID]['player_energy_match_helper_flag'] = 1

    end
end



function initTempPlayerPower()
    for playerID = 0, 9 do --10个玩家的数据包 
        PlayerPower[playerID]["electric_shock_a"] = nil
        PlayerPower[playerID]["electric_shock_b"] = nil

        PlayerPower[playerID]['temp_vision'] = 0
        PlayerPower[playerID]['temp_vision_precent_base'] = 0
        PlayerPower[playerID]['temp_vision_precent_final'] = 0     

        PlayerPower[playerID]['temp_speed'] = 0
        PlayerPower[playerID]['temp_speed_precent_base'] = 0
        PlayerPower[playerID]['temp_speed_precent_final'] = 0    

        PlayerPower[playerID]['temp_health'] = 0     
        PlayerPower[playerID]['temp_health_precent_base'] = 0
        PlayerPower[playerID]['temp_health_precent_final'] = 0  

        PlayerPower[playerID]['temp_mana'] = 0     
        PlayerPower[playerID]['temp_mana_precent_base'] = 0
        PlayerPower[playerID]['temp_mana_precent_final'] = 0

        PlayerPower[playerID]['temp_mana_regen'] = 0     
        PlayerPower[playerID]['temp_mana_regen_precent_base'] = 0
        PlayerPower[playerID]['temp_mana_regen_precent_final'] = 0

        --技能能力
        PlayerPower[playerID]['temp_ability_speed_d'] = 0
        PlayerPower[playerID]['temp_ability_speed_d_precent_base'] = 0
        PlayerPower[playerID]['temp_ability_speed_d_precent_final'] = 0
        PlayerPower[playerID]['temp_ability_speed_c'] = 0
        PlayerPower[playerID]['temp_ability_speed_c_precent_base'] = 0
        PlayerPower[playerID]['temp_ability_speed_c_precent_final'] = 0
        PlayerPower[playerID]['temp_ability_speed_b'] = 0
        PlayerPower[playerID]['temp_ability_speed_b_precent_base'] = 0
        PlayerPower[playerID]['temp_ability_speed_b_precent_final'] = 0
        PlayerPower[playerID]['temp_ability_speed_a'] = 0
        PlayerPower[playerID]['temp_ability_speed_a_precent_base'] = 0
        PlayerPower[playerID]['temp_ability_speed_a_precent_final'] = 0

        PlayerPower[playerID]['temp_range_d'] = 0
        PlayerPower[playerID]['temp_range_d_precent_base'] = 0
        PlayerPower[playerID]['temp_range_d_precent_final'] = 0
        PlayerPower[playerID]['temp_range_c'] = 0
        PlayerPower[playerID]['temp_range_c_precent_base'] = 0
        PlayerPower[playerID]['temp_range_c_precent_final'] = 0
        PlayerPower[playerID]['temp_range_b'] = 0
        PlayerPower[playerID]['temp_range_b_precent_base'] = 0
        PlayerPower[playerID]['temp_range_b_precent_final'] = 0
        PlayerPower[playerID]['temp_range_a'] = 0
        PlayerPower[playerID]['temp_range_a_precent_base'] = 0
        PlayerPower[playerID]['temp_range_a_precent_final'] = 0

        PlayerPower[playerID]['temp_radius_d'] = 0
        PlayerPower[playerID]['temp_radius_d_precent_base'] = 0
        PlayerPower[playerID]['temp_radius_d_precent_final'] = 0
        PlayerPower[playerID]['temp_radius_c'] = 0
        PlayerPower[playerID]['temp_radius_c_precent_base'] = 0
        PlayerPower[playerID]['temp_radius_c_precent_final'] = 0
        PlayerPower[playerID]['temp_radius_b'] = 0
        PlayerPower[playerID]['temp_radius_b_precent_base'] = 0
        PlayerPower[playerID]['temp_radius_b_precent_final'] = 0
        PlayerPower[playerID]['temp_radius_a'] = 0
        PlayerPower[playerID]['temp_radius_a_precent_base'] = 0
        PlayerPower[playerID]['temp_radius_a_precent_final'] = 0

        PlayerPower[playerID]['temp_mana_cost_d'] = 0
        PlayerPower[playerID]['temp_mana_cost_d_precent'] = 0
        PlayerPower[playerID]['temp_mana_cost_c'] = 0
        PlayerPower[playerID]['temp_mana_cost_c_precent'] = 0
        PlayerPower[playerID]['temp_mana_cost_b'] = 0
        PlayerPower[playerID]['temp_mana_cost_b_precent'] = 0
        PlayerPower[playerID]['temp_mana_cost_a'] = 0
        PlayerPower[playerID]['temp_mana_cost_a_precent'] = 0

        PlayerPower[playerID]['temp_damage_d'] = 0
        PlayerPower[playerID]['temp_damage_d_precent_base'] = 0
        PlayerPower[playerID]['temp_damage_d_precent_final'] = 0
        PlayerPower[playerID]['temp_damage_c'] = 0
        PlayerPower[playerID]['temp_damage_c_precent_base'] = 0
        PlayerPower[playerID]['temp_damage_c_precent_final'] = 0
        PlayerPower[playerID]['temp_damage_b'] = 0
        PlayerPower[playerID]['temp_damage_b_precent_base'] = 0
        PlayerPower[playerID]['temp_damage_b_precent_final'] = 0
        PlayerPower[playerID]['temp_damage_a'] = 0
        PlayerPower[playerID]['temp_damage_a_precent_base'] = 0
        PlayerPower[playerID]['temp_damage_a_precent_final'] = 0

        PlayerPower[playerID]['temp_damage_match_d'] = 0
        PlayerPower[playerID]['temp_damage_match_d_precent_base'] = 0
        PlayerPower[playerID]['temp_damage_match_d_precent_final'] = 0
        PlayerPower[playerID]['temp_damage_match_c'] = 0
        PlayerPower[playerID]['temp_damage_match_c_precent_base'] = 0
        PlayerPower[playerID]['temp_damage_match_c_precent_final'] = 0
        PlayerPower[playerID]['temp_damage_match_b'] = 0
        PlayerPower[playerID]['temp_damage_match_b_precent_base'] = 0
        PlayerPower[playerID]['temp_damage_match_b_precent_final'] = 0
        PlayerPower[playerID]['temp_damage_match_a'] = 0
        PlayerPower[playerID]['temp_damage_match_a_precent_base'] = 0
        PlayerPower[playerID]['temp_damage_match_a_precent_final'] = 0

        PlayerPower[playerID]['temp_damage_match_helper_d'] = 0
        PlayerPower[playerID]['temp_damage_match_helper_d_precent_base'] = 0
        PlayerPower[playerID]['temp_damage_match_helper_d_precent_final'] = 0
        PlayerPower[playerID]['temp_damage_match_helper_c'] = 0
        PlayerPower[playerID]['temp_damage_match_helper_c_precent_base'] = 0
        PlayerPower[playerID]['temp_damage_match_helper_c_precent_final'] = 0
        PlayerPower[playerID]['temp_damage_match_helper_b'] = 0
        PlayerPower[playerID]['temp_damage_match_helper_b_precent_base'] = 0
        PlayerPower[playerID]['temp_damage_match_helper_b_precent_final'] = 0
        PlayerPower[playerID]['temp_damage_match_helper_a'] = 0
        PlayerPower[playerID]['temp_damage_match_helper_a_precent_base'] = 0
        PlayerPower[playerID]['temp_damage_match_helper_a_precent_final'] = 0

        PlayerPower[playerID]['temp_control_d'] = 0
        PlayerPower[playerID]['temp_control_d_precent_base'] = 0
        PlayerPower[playerID]['temp_control_d_precent_final'] = 0
        PlayerPower[playerID]['temp_control_c'] = 0
        PlayerPower[playerID]['temp_control_c_precent_base'] = 0
        PlayerPower[playerID]['temp_control_c_precent_final'] = 0
        PlayerPower[playerID]['temp_control_b'] = 0
        PlayerPower[playerID]['temp_control_b_precent_base'] = 0
        PlayerPower[playerID]['temp_control_b_precent_final'] = 0
        PlayerPower[playerID]['temp_control_a'] = 0
        PlayerPower[playerID]['temp_control_a_precent_base'] = 0
        PlayerPower[playerID]['temp_control_a_precent_final'] = 0

        PlayerPower[playerID]['temp_control_match_d'] = 0
        PlayerPower[playerID]['temp_control_match_d_precent_base'] = 0
        PlayerPower[playerID]['temp_control_match_d_precent_final'] = 0
        PlayerPower[playerID]['temp_control_match_c'] = 0
        PlayerPower[playerID]['temp_control_match_c_precent_base'] = 0
        PlayerPower[playerID]['temp_control_match_c_precent_final'] = 0
        PlayerPower[playerID]['temp_control_match_b'] = 0
        PlayerPower[playerID]['temp_control_match_b_precent_base'] = 0
        PlayerPower[playerID]['temp_control_match_b_precent_final'] = 0
        PlayerPower[playerID]['temp_control_match_a'] = 0
        PlayerPower[playerID]['temp_control_match_a_precent_base'] = 0
        PlayerPower[playerID]['temp_control_match_a_precent_final'] = 0

        PlayerPower[playerID]['temp_control_match_helper_d'] = 0
        PlayerPower[playerID]['temp_control_match_helper_d_precent_base'] = 0
        PlayerPower[playerID]['temp_control_match_helper_d_precent_final'] = 0
        PlayerPower[playerID]['temp_control_match_helper_c'] = 0
        PlayerPower[playerID]['temp_control_match_helper_c_precent_base'] = 0
        PlayerPower[playerID]['temp_control_match_helper_c_precent_final'] = 0
        PlayerPower[playerID]['temp_control_match_helper_b'] = 0
        PlayerPower[playerID]['temp_control_match_helper_b_precent_base'] = 0
        PlayerPower[playerID]['temp_control_match_helper_b_precent_final'] = 0
        PlayerPower[playerID]['temp_control_match_helper_a'] = 0
        PlayerPower[playerID]['temp_control_match_helper_a_precent_base'] = 0
        PlayerPower[playerID]['temp_control_match_helper_a_precent_final'] = 0
      
        PlayerPower[playerID]['temp_energy_d'] = 0
        PlayerPower[playerID]['temp_energy_d_precent_base'] = 0
        PlayerPower[playerID]['temp_energy_d_precent_final'] = 0
        PlayerPower[playerID]['temp_energy_c'] = 0
        PlayerPower[playerID]['temp_energy_c_precent_base'] = 0
        PlayerPower[playerID]['temp_energy_c_precent_final'] = 0
        PlayerPower[playerID]['temp_energy_b'] = 0
        PlayerPower[playerID]['temp_energy_b_precent_base'] = 0
        PlayerPower[playerID]['temp_energy_b_precent_final'] = 0
        PlayerPower[playerID]['temp_energy_a'] = 0
        PlayerPower[playerID]['temp_energy_a_precent_base'] = 0
        PlayerPower[playerID]['temp_energy_a_precent_final'] = 0

        PlayerPower[playerID]['temp_energy_match_d'] = 0
        PlayerPower[playerID]['temp_energy_match_d_precent_base'] = 0
        PlayerPower[playerID]['temp_energy_match_d_precent_final'] = 0
        PlayerPower[playerID]['temp_energy_match_c'] = 0
        PlayerPower[playerID]['temp_energy_match_c_precent_base'] = 0
        PlayerPower[playerID]['temp_energy_match_c_precent_final'] = 0
        PlayerPower[playerID]['temp_energy_match_b'] = 0
        PlayerPower[playerID]['temp_energy_match_b_precent_base'] = 0
        PlayerPower[playerID]['temp_energy_match_b_precent_final'] = 0
        PlayerPower[playerID]['temp_energy_match_a'] = 0
        PlayerPower[playerID]['temp_energy_match_a_precent_base'] = 0
        PlayerPower[playerID]['temp_energy_match_a_precent_final'] = 0

        PlayerPower[playerID]['temp_energy_match_helper_d'] = 0
        PlayerPower[playerID]['temp_energy_match_helper_d_precent_base'] = 0
        PlayerPower[playerID]['temp_energy_match_helper_d_precent_final'] = 0
        PlayerPower[playerID]['temp_energy_match_helper_c'] = 0
        PlayerPower[playerID]['temp_energy_match_helper_c_precent_base'] = 0
        PlayerPower[playerID]['temp_energy_match_helper_c_precent_final'] = 0
        PlayerPower[playerID]['temp_energy_match_helper_b'] = 0
        PlayerPower[playerID]['temp_energy_match_helper_b_precent_base'] = 0
        PlayerPower[playerID]['temp_energy_match_helper_b_precent_final'] = 0
        PlayerPower[playerID]['temp_energy_match_helper_a'] = 0
        PlayerPower[playerID]['temp_energy_match_helper_a_precent_base'] = 0
        PlayerPower[playerID]['temp_energy_match_helper_a_precent_final'] = 0

        if PlayerResource:GetConnectionState(playerID) == DOTA_CONNECTION_STATE_CONNECTED then 
            print("removeremove",playerID)
            local hero = PlayerResource:GetSelectedHeroEntity(playerID)
            removePlayerBuffByAbilityAndModifier(hero, "ability_health_control_temp", "modifier_health_buff_temp","modifier_health_debuff_temp")
            removePlayerBuffByAbilityAndModifier(hero, "ability_vision_control_temp", "modifier_vision_buff_temp","modifier_vision_debuff_temp")
            removePlayerBuffByAbilityAndModifier(hero, "ability_speed_control_temp", "modifier_speed_buff_temp","modifier_speed_debuff_temp")
            removePlayerBuffByAbilityAndModifier(hero, "ability_mana_control_temp", "modifier_mana_buff_temp","modifier_mana_debuff_temp")
            removePlayerBuffByAbilityAndModifier(hero, "ability_mana_regen_control_temp", "modifier_mana_regen_buff_temp","modifier_mana_regen_debuff_temp")
            removePlayerBuffByAbilityAndModifier(hero, "ability_health_control_duration", "modifier_health_buff_duration","modifier_health_debuff_duration")
            removePlayerBuffByAbilityAndModifier(hero, "ability_vision_control_duration", "modifier_vision_buff_duration","modifier_vision_debuff_duration")
            removePlayerBuffByAbilityAndModifier(hero, "ability_speed_control_duration", "modifier_speed_buff_duration","modifier_speed_debuff_duration")
            removePlayerBuffByAbilityAndModifier(hero, "ability_mana_control_duration", "modifier_mana_buff_duration","modifier_mana_debuff_duration")
            removePlayerBuffByAbilityAndModifier(hero, "ability_mana_regen_control_duration", "modifier_mana_regen_buff_duration","modifier_mana_regen_debuff_duration")
        end
    end
    
end