--永久类modifier
--装备，契约，神符，铭文临时等能力用
function setPlayerBuffByNameAndBValue(keys,buffName,baseValue)
    local hero = keys.caster
    local playerID = hero:GetPlayerID()
    local modifierNameAdd
    local modifierNameRemove
    local abilityName = "ability_"..buffName.."_control"
    local modifierNameBuff = "modifier_"..buffName.."_buff"  
    local modifierNameDebuff = "modifier_"..buffName.."_debuff"
    local modifierStackCount =  getFinalValueOperation(playerID,baseValue,buffName,nil,'buffStack')
    --print("setPlayerBuffByAbilityAndModifier",abilityName)
    --print(modifierNameBuff,"==",modifierNameDebuff)
    --print("modifierNameCount=",modifierStackCount)
    removePlayerBuffByAbilityAndModifier(hero, abilityName, modifierNameBuff,modifierNameDebuff)

    if modifierStackCount ~= 0 then
        if (modifierStackCount > 0) then   
            modifierNameAdd = modifierNameBuff
            modifierNameRemove = modifierNameDebuff
        else
            modifierNameAdd = modifierNameDebuff
            modifierNameRemove = modifierNameBuff
            modifierStackCount = modifierStackCount * -1
        end
        --print("modifierNameAdd",modifierNameAdd,modifierStackCount)
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


function removePlayerBuffByAbilityAndModifier(hero, abilityName, modifierNameBuff, modifierNameDebuff)
    --print("removePlayerBuffByAbilityAndModifier")
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
    --print("setPlayerPower==",playerID)
    if( not isAdd ) then
        value = value * -1
    end
    --print(powerName.."=="..value)
    PlayerPower[playerID][powerName] = PlayerPower[playerID][powerName] + value
    --print("PlayerPower=="..PlayerPower[playerID][powerName])
end

function setPlayerPowerFlag(playerID, powerName, value)
    --print("setPlayerPowerFlag:"..powerName.."="..value)
    PlayerPower[playerID][powerName] = value
end


--能力数值运算，获取装备与辅助buff的计算值
function getFinalValueOperation(playerID,baseValue,buffName,abilityLevel,type)
    local abilityBuffName = buffName
    if abilityLevel ~= nil then
        abilityBuffName = buffName.."_"..abilityLevel
    end
	--print("getFinalValueOperation"..playerID..abilityBuffName)
    --固定增加能力专用（铭文与其他）
    local talentPrecentBase = PlayerPower[playerID]['talent_'..abilityBuffName..'_precent_base'] / 100
	local talentBonusValue = PlayerPower[playerID]['talent_'..abilityBuffName]
	local talentPrecentFinal = PlayerPower[playerID]['talent_'..abilityBuffName..'_precent_final'] / 100

    --契约专用（固定能力）（有正负）
	local contractPrecentBase = PlayerPower[playerID]['contract_'..abilityBuffName..'_precent_base'] / 100
	local contractBonusValue = PlayerPower[playerID]['contract_'..abilityBuffName]
	local contractPrecentFinal = PlayerPower[playerID]['contract_'..abilityBuffName..'_precent_final'] / 100

    --装备专用（非固定能力）
	local equipPrecentBase = PlayerPower[playerID]['player_'..abilityBuffName..'_precent_base'] / 100
	local equipBonusValue = PlayerPower[playerID]['player_'..abilityBuffName]
	local equipPrecentFinal = PlayerPower[playerID]['player_'..abilityBuffName..'_precent_final'] / 100

    --单回合能力专用
	local tempPrecentBase = PlayerPower[playerID]['temp_'..abilityBuffName..'_precent_base'] / 100
	local tempBonusValue = PlayerPower[playerID]['temp_'..abilityBuffName]
	local tempPrecentFinal = PlayerPower[playerID]['temp_'..abilityBuffName..'_precent_final'] / 100
    
    --法阵神符专用（专用）
	local battlefieldPrecentBase = PlayerPower[playerID]['battlefield_'..abilityBuffName..'_precent_base'] / 100
	local battlefieldBonusValue = PlayerPower[playerID]['battlefield_'..abilityBuffName]
	local battlefieldPrecentFinal = PlayerPower[playerID]['battlefield_'..abilityBuffName..'_precent_final'] / 100

	--print("getFinalValueOperation")
	--print(precentBase..","..bonusValue..","..precentFinal)
	--print(equipPrecentBase..","..equipBonusValue..","..equipPrecentFinal)
	local flag = PlayerPower[playerID]['contract_'..buffName..'_flag']
    --print(flag)
    --装备不受加强的契约使用
    if (equipPrecentBase > 0) then
        equipPrecentBase = equipPrecentBase * flag
    end
    if (equipBonusValue > 0) then
        equipBonusValue = equipBonusValue * flag
    end
    if (equipPrecentFinal > 0) then
        equipPrecentFinal = equipPrecentFinal * flag
    end

    local precentBaseTotal =  contractPrecentBase + equipPrecentBase + talentPrecentBase + battlefieldPrecentBase + tempPrecentBase
    local bonusValueTotal = contractBonusValue + equipBonusValue + talentBonusValue + battlefieldBonusValue + tempBonusValue
    local precentFinalTotal = contractPrecentFinal + equipPrecentFinal + talentPrecentFinal + battlefieldPrecentFinal + tempPrecentFinal

	local operationValue =  (baseValue * (1 + precentBaseTotal ) + bonusValueTotal) * (1 + precentFinalTotal)

    if type == 'buffStack' then
        operationValue  =  operationValue - baseValue
    end

	return operationValue
end

--基础属性数据包
function initPlayerPower()
    PlayerPower={}
    for playerID = 0, 9 do --10个玩家的数据包
        PlayerPower[playerID] = {} 
        local talentType = "talent" --铭文和其他局内能力
        local playerType = "player" --装备
        local contractType = "contract" --契约
        --Modifiers能力
        --铭文初始化
        initPlayerPowerOPeration(playerID,talentType)
        --装备加强初始化
        initPlayerPowerOPeration(playerID,playerType)
        --装备受契约flag控制初始化
        initPlayerPowerFlagOPeration(playerID,contractType)
        --契约初始化
        initPlayerPowerOPeration(playerID,contractType)

        --英雄临时能力容器
        local tempType = "temp" --装备临时
        local battlefieldType = "battlefield" --法阵临时
        initPlayerPowerOPeration(playerID,tempType)
        initPlayerPowerOPeration(playerID,battlefieldType)
    end
end


--用于回合重置能力
function initTempPlayerPower()
    for playerID = 0, 9 do --10个玩家的数据包   
        if PlayerResource:GetConnectionState(playerID) ~= DOTA_CONNECTION_STATE_UNKNOWN then 
             --用于记录正负电击的两个电极子弹
            PlayerPower[playerID]["electric_shock_a"] = nil
            PlayerPower[playerID]["electric_shock_b"] = nil
            print("removeremove",playerID)
            local hero = PlayerResource:GetSelectedHeroEntity(playerID)
            --法阵神符
            removeBattlefieldBuff(hero)
            --装备临时能力
            removeTempBuff(hero)
        end
    end
end

--获取冷却缩减后的充能时间(弃用！)
function getCooldownChargeReplenish(playerID,charge_replenish_time)
    local cooldown = getFinalValueOperation(playerID,0,'cooldown',nil,nil)
    print("cooldown:"..cooldown)
	if cooldown >= 100 then
		cooldown = 95
	end
	charge_replenish_time = charge_replenish_time * (1 - cooldown / 100)
    return charge_replenish_time
end


--"battlefield_mana_regen_buff_datadriven"
--移除法阵神符能力
function removeBattlefieldBuff(hero)
    removePlayerBuffByAbilityAndModifier(hero, "battlefield_health_buff_datadriven", "modifier_battlefield_health_buff_datadriven","nil")
    removePlayerBuffByAbilityAndModifier(hero, "battlefield_vision_buff_datadriven", "modifier_battlefield_vision_buff_datadriven","nil")
    removePlayerBuffByAbilityAndModifier(hero, "battlefield_speed_buff_datadriven", "modifier_battlefield_speed_buff_datadriven","nil")
    removePlayerBuffByAbilityAndModifier(hero, "battlefield_mana_buff_datadriven", "modifier_battlefield_mana_buff_datadriven","nil")
    removePlayerBuffByAbilityAndModifier(hero, "battlefield_mana_regen_buff_datadriven", "modifier_battlefield_mana_regen_buff_datadriven","nil")

end

--移除装备临时能力（未做）
function removeTempBuff(hero)
    --[[
    removePlayerBuffByAbilityAndModifier(hero, "ability_health_control_temp", "modifier_health_buff_temp","modifier_health_debuff_temp")
    removePlayerBuffByAbilityAndModifier(hero, "ability_vision_control_temp", "modifier_vision_buff_temp","modifier_vision_debuff_temp")
    removePlayerBuffByAbilityAndModifier(hero, "ability_speed_control_temp", "modifier_speed_buff_temp","modifier_speed_debuff_temp")
    removePlayerBuffByAbilityAndModifier(hero, "ability_mana_control_temp", "modifier_mana_buff_temp","modifier_mana_debuff_temp")
    removePlayerBuffByAbilityAndModifier(hero, "ability_mana_regen_control_temp", "modifier_mana_regen_buff_temp","modifier_mana_regen_debuff_temp")
    ]]
end

function initPlayerPowerOPeration(playerID,powerType)
    PlayerPower[playerID][powerType .. '_vision'] = 0
    PlayerPower[playerID][powerType .. '_vision_precent_base'] = 0
    PlayerPower[playerID][powerType .. '_vision_precent_final'] = 0

    PlayerPower[playerID][powerType .. '_speed'] = 0
    PlayerPower[playerID][powerType .. '_speed_precent_base'] = 0
    PlayerPower[playerID][powerType .. '_speed_precent_final'] = 0 
    
    PlayerPower[playerID][powerType .. '_health'] = 0     
    PlayerPower[playerID][powerType .. '_health_precent_base'] = 0
    PlayerPower[playerID][powerType .. '_health_precent_final'] = 0 
    
    PlayerPower[playerID][powerType .. '_mana'] = 0     
    PlayerPower[playerID][powerType .. '_mana_precent_base'] = 0
    PlayerPower[playerID][powerType .. '_mana_precent_final'] = 0
    
    PlayerPower[playerID][powerType .. '_mana_regen'] = 0
    PlayerPower[playerID][powerType .. '_mana_regen_precent_base'] = 0
    PlayerPower[playerID][powerType .. '_mana_regen_precent_final'] = 0

    PlayerPower[playerID][powerType .. '_defense'] = 0     
    PlayerPower[playerID][powerType .. '_defense_precent_base'] = 0
    PlayerPower[playerID][powerType .. '_defense_precent_final'] = 0

    PlayerPower[playerID][powerType .. '_cooldown'] = 0
    PlayerPower[playerID][powerType .. '_cooldown_precent_base'] = 0
    PlayerPower[playerID][powerType .. '_cooldown_precent_final'] = 0

    --技能能力
    PlayerPower[playerID][powerType .. '_ability_speed_d'] = 0
    PlayerPower[playerID][powerType .. '_ability_speed_d_precent_base'] = 0
    PlayerPower[playerID][powerType .. '_ability_speed_d_precent_final'] = 0
    PlayerPower[playerID][powerType .. '_ability_speed_c'] = 0
    PlayerPower[playerID][powerType .. '_ability_speed_c_precent_base'] = 0
    PlayerPower[playerID][powerType .. '_ability_speed_c_precent_final'] = 0
    PlayerPower[playerID][powerType .. '_ability_speed_b'] = 0
    PlayerPower[playerID][powerType .. '_ability_speed_b_precent_base'] = 0
    PlayerPower[playerID][powerType .. '_ability_speed_b_precent_final'] = 0
    PlayerPower[playerID][powerType .. '_ability_speed_a'] = 0
    PlayerPower[playerID][powerType .. '_ability_speed_a_precent_base'] = 0
    PlayerPower[playerID][powerType .. '_ability_speed_a_precent_final'] = 0

    PlayerPower[playerID][powerType .. '_range_d'] = 0
    PlayerPower[playerID][powerType .. '_range_d_precent_base'] = 0
    PlayerPower[playerID][powerType .. '_range_d_precent_final'] = 0
    PlayerPower[playerID][powerType .. '_range_c'] = 0
    PlayerPower[playerID][powerType .. '_range_c_precent_base'] = 0
    PlayerPower[playerID][powerType .. '_range_c_precent_final'] = 0
    PlayerPower[playerID][powerType .. '_range_b'] = 0
    PlayerPower[playerID][powerType .. '_range_b_precent_base'] = 0
    PlayerPower[playerID][powerType .. '_range_b_precent_final'] = 0
    PlayerPower[playerID][powerType .. '_range_a'] = 0
    PlayerPower[playerID][powerType .. '_range_a_precent_base'] = 0
    PlayerPower[playerID][powerType .. '_range_a_precent_final'] = 0

    PlayerPower[playerID][powerType .. '_radius_d'] = 0
    PlayerPower[playerID][powerType .. '_radius_d_precent_base'] = 0
    PlayerPower[playerID][powerType .. '_radius_d_precent_final'] = 0
    PlayerPower[playerID][powerType .. '_radius_c'] = 0
    PlayerPower[playerID][powerType .. '_radius_c_precent_base'] = 0
    PlayerPower[playerID][powerType .. '_radius_c_precent_final'] = 0
    PlayerPower[playerID][powerType .. '_radius_b'] = 0
    PlayerPower[playerID][powerType .. '_radius_b_precent_base'] = 0
    PlayerPower[playerID][powerType .. '_radius_b_precent_final'] = 0
    PlayerPower[playerID][powerType .. '_radius_a'] = 0
    PlayerPower[playerID][powerType .. '_radius_a_precent_base'] = 0
    PlayerPower[playerID][powerType .. '_radius_a_precent_final'] = 0

    PlayerPower[playerID][powerType .. '_mana_cost_d'] = 0
    PlayerPower[playerID][powerType .. '_mana_cost_d_precent_base'] = 0
    PlayerPower[playerID][powerType .. '_mana_cost_d_precent_final'] = 0
    PlayerPower[playerID][powerType .. '_mana_cost_c'] = 0
    PlayerPower[playerID][powerType .. '_mana_cost_c_precent_base'] = 0
    PlayerPower[playerID][powerType .. '_mana_cost_c_precent_final'] = 0
    PlayerPower[playerID][powerType .. '_mana_cost_b'] = 0
    PlayerPower[playerID][powerType .. '_mana_cost_b_precent_base'] = 0
    PlayerPower[playerID][powerType .. '_mana_cost_b_precent_final'] = 0
    PlayerPower[playerID][powerType .. '_mana_cost_a'] = 0
    PlayerPower[playerID][powerType .. '_mana_cost_a_precent_base'] = 0
    PlayerPower[playerID][powerType .. '_mana_cost_a_precent_final'] = 0

    PlayerPower[playerID][powerType .. '_damage_d'] = 0
    PlayerPower[playerID][powerType .. '_damage_d_precent_base'] = 0
    PlayerPower[playerID][powerType .. '_damage_d_precent_final'] = 0
    PlayerPower[playerID][powerType .. '_damage_c'] = 0
    PlayerPower[playerID][powerType .. '_damage_c_precent_base'] = 0
    PlayerPower[playerID][powerType .. '_damage_c_precent_final'] = 0
    PlayerPower[playerID][powerType .. '_damage_b'] = 0
    PlayerPower[playerID][powerType .. '_damage_b_precent_base'] = 0
    PlayerPower[playerID][powerType .. '_damage_b_precent_final'] = 0
    PlayerPower[playerID][powerType .. '_damage_a'] = 0
    PlayerPower[playerID][powerType .. '_damage_a_precent_base'] = 0
    PlayerPower[playerID][powerType .. '_damage_a_precent_final'] = 0
    PlayerPower[playerID][powerType .. '_damage_match_d'] = 0
    PlayerPower[playerID][powerType .. '_damage_match_d_precent_base'] = 0
    PlayerPower[playerID][powerType .. '_damage_match_d_precent_final'] = 0
    PlayerPower[playerID][powerType .. '_damage_match_c'] = 0
    PlayerPower[playerID][powerType .. '_damage_match_c_precent_base'] = 0
    PlayerPower[playerID][powerType .. '_damage_match_c_precent_final'] = 0
    PlayerPower[playerID][powerType .. '_damage_match_b'] = 0
    PlayerPower[playerID][powerType .. '_damage_match_b_precent_base'] = 0
    PlayerPower[playerID][powerType .. '_damage_match_b_precent_final'] = 0
    PlayerPower[playerID][powerType .. '_damage_match_a'] = 0
    PlayerPower[playerID][powerType .. '_damage_match_a_precent_base'] = 0
    PlayerPower[playerID][powerType .. '_damage_match_a_precent_final'] = 0

    PlayerPower[playerID][powerType .. '_damage_match_helper_d'] = 0
    PlayerPower[playerID][powerType .. '_damage_match_helper_d_precent_base'] = 0
    PlayerPower[playerID][powerType .. '_damage_match_helper_d_precent_final'] = 0
    PlayerPower[playerID][powerType .. '_damage_match_helper_c'] = 0
    PlayerPower[playerID][powerType .. '_damage_match_helper_c_precent_base'] = 0
    PlayerPower[playerID][powerType .. '_damage_match_helper_c_precent_final'] = 0
    PlayerPower[playerID][powerType .. '_damage_match_helper_b'] = 0
    PlayerPower[playerID][powerType .. '_damage_match_helper_b_precent_base'] = 0
    PlayerPower[playerID][powerType .. '_damage_match_helper_b_precent_final'] = 0
    PlayerPower[playerID][powerType .. '_damage_match_helper_a'] = 0
    PlayerPower[playerID][powerType .. '_damage_match_helper_a_precent_base'] = 0
    PlayerPower[playerID][powerType .. '_damage_match_helper_a_precent_final'] = 0

    PlayerPower[playerID][powerType .. '_control_d'] = 0
    PlayerPower[playerID][powerType .. '_control_d_precent_base'] = 0
    PlayerPower[playerID][powerType .. '_control_d_precent_final'] = 0
    PlayerPower[playerID][powerType .. '_control_c'] = 0
    PlayerPower[playerID][powerType .. '_control_c_precent_base'] = 0
    PlayerPower[playerID][powerType .. '_control_c_precent_final'] = 0
    PlayerPower[playerID][powerType .. '_control_b'] = 0
    PlayerPower[playerID][powerType .. '_control_b_precent_base'] = 0
    PlayerPower[playerID][powerType .. '_control_b_precent_final'] = 0
    PlayerPower[playerID][powerType .. '_control_a'] = 0
    PlayerPower[playerID][powerType .. '_control_a_precent_base'] = 0
    PlayerPower[playerID][powerType .. '_control_a_precent_final'] = 0

    PlayerPower[playerID][powerType .. '_control_match_d'] = 0
    PlayerPower[playerID][powerType .. '_control_match_d_precent_base'] = 0
    PlayerPower[playerID][powerType .. '_control_match_d_precent_final'] = 0
    PlayerPower[playerID][powerType .. '_control_match_c'] = 0
    PlayerPower[playerID][powerType .. '_control_match_c_precent_base'] = 0
    PlayerPower[playerID][powerType .. '_control_match_c_precent_final'] = 0
    PlayerPower[playerID][powerType .. '_control_match_b'] = 0
    PlayerPower[playerID][powerType .. '_control_match_b_precent_base'] = 0
    PlayerPower[playerID][powerType .. '_control_match_b_precent_final'] = 0
    PlayerPower[playerID][powerType .. '_control_match_a'] = 0
    PlayerPower[playerID][powerType .. '_control_match_a_precent_base'] = 0
    PlayerPower[playerID][powerType .. '_control_match_a_precent_final'] = 0

    PlayerPower[playerID][powerType .. '_control_match_helper_d'] = 0
    PlayerPower[playerID][powerType .. '_control_match_helper_d_precent_base'] = 0
    PlayerPower[playerID][powerType .. '_control_match_helper_d_precent_final'] = 0
    PlayerPower[playerID][powerType .. '_control_match_helper_c'] = 0
    PlayerPower[playerID][powerType .. '_control_match_helper_c_precent_base'] = 0
    PlayerPower[playerID][powerType .. '_control_match_helper_c_precent_final'] = 0
    PlayerPower[playerID][powerType .. '_control_match_helper_b'] = 0
    PlayerPower[playerID][powerType .. '_control_match_helper_b_precent_base'] = 0
    PlayerPower[playerID][powerType .. '_control_match_helper_b_precent_final'] = 0
    PlayerPower[playerID][powerType .. '_control_match_helper_a'] = 0
    PlayerPower[playerID][powerType .. '_control_match_helper_a_precent_base'] = 0
    PlayerPower[playerID][powerType .. '_control_match_helper_a_precent_final'] = 0
    
    PlayerPower[playerID][powerType .. '_energy_d'] = 0
    PlayerPower[playerID][powerType .. '_energy_d_precent_base'] = 0
    PlayerPower[playerID][powerType .. '_energy_d_precent_final'] = 0
    PlayerPower[playerID][powerType .. '_energy_c'] = 0
    PlayerPower[playerID][powerType .. '_energy_c_precent_base'] = 0
    PlayerPower[playerID][powerType .. '_energy_c_precent_final'] = 0
    PlayerPower[playerID][powerType .. '_energy_b'] = 0
    PlayerPower[playerID][powerType .. '_energy_b_precent_base'] = 0
    PlayerPower[playerID][powerType .. '_energy_b_precent_final'] = 0
    PlayerPower[playerID][powerType .. '_energy_a'] = 0
    PlayerPower[playerID][powerType .. '_energy_a_precent_base'] = 0
    PlayerPower[playerID][powerType .. '_energy_a_precent_final'] = 0

    PlayerPower[playerID][powerType .. '_energy_match_d'] = 0
    PlayerPower[playerID][powerType .. '_energy_match_d_precent_base'] = 0
    PlayerPower[playerID][powerType .. '_energy_match_d_precent_final'] = 0
    PlayerPower[playerID][powerType .. '_energy_match_c'] = 0
    PlayerPower[playerID][powerType .. '_energy_match_c_precent_base'] = 0
    PlayerPower[playerID][powerType .. '_energy_match_c_precent_final'] = 0
    PlayerPower[playerID][powerType .. '_energy_match_b'] = 0
    PlayerPower[playerID][powerType .. '_energy_match_b_precent_base'] = 0
    PlayerPower[playerID][powerType .. '_energy_match_b_precent_final'] = 0
    PlayerPower[playerID][powerType .. '_energy_match_a'] = 0
    PlayerPower[playerID][powerType .. '_energy_match_a_precent_base'] = 0
    PlayerPower[playerID][powerType .. '_energy_match_a_precent_final'] = 0

    PlayerPower[playerID][powerType .. '_energy_match_helper_d'] = 0
    PlayerPower[playerID][powerType .. '_energy_match_helper_d_precent_base'] = 0
    PlayerPower[playerID][powerType .. '_energy_match_helper_d_precent_final'] = 0
    PlayerPower[playerID][powerType .. '_energy_match_helper_c'] = 0
    PlayerPower[playerID][powerType .. '_energy_match_helper_c_precent_base'] = 0
    PlayerPower[playerID][powerType .. '_energy_match_helper_c_precent_final'] = 0
    PlayerPower[playerID][powerType .. '_energy_match_helper_b'] = 0
    PlayerPower[playerID][powerType .. '_energy_match_helper_b_precent_base'] = 0
    PlayerPower[playerID][powerType .. '_energy_match_helper_b_precent_final'] = 0
    PlayerPower[playerID][powerType .. '_energy_match_helper_a'] = 0
    PlayerPower[playerID][powerType .. '_energy_match_helper_a_precent_base'] = 0
    PlayerPower[playerID][powerType .. '_energy_match_helper_a_precent_final'] = 0
end

function initPlayerPowerFlagOPeration(playerID,powerType)

    PlayerPower[playerID][powerType .. '_vision_flag'] = 1
    PlayerPower[playerID][powerType .. '_speed_flag'] = 1
    PlayerPower[playerID][powerType .. '_health_flag'] = 1
    PlayerPower[playerID][powerType .. '_mana_flag'] = 1
    PlayerPower[playerID][powerType .. '_mana_regen_flag'] = 1
    PlayerPower[playerID][powerType .. '_defense_flag'] = 1
    PlayerPower[playerID][powerType .. '_cooldown_flag'] = 1
    --技能能力
    PlayerPower[playerID][powerType .. '_ability_speed_flag'] = 1
    PlayerPower[playerID][powerType .. '_range_flag'] = 1
    PlayerPower[playerID][powerType .. '_radius_flag'] = 1
    PlayerPower[playerID][powerType .. '_mana_cost_flag'] = 1
    PlayerPower[playerID][powerType .. '_damage_flag'] = 1
    PlayerPower[playerID][powerType .. '_damage_match_flag'] = 1
    PlayerPower[playerID][powerType .. '_damage_match_helper_flag'] = 1
    PlayerPower[playerID][powerType .. '_control_flag'] = 1
    PlayerPower[playerID][powerType .. '_control_match_flag'] = 1
    PlayerPower[playerID][powerType .. '_control_match_helper_flag'] = 1
    PlayerPower[playerID][powerType .. '_energy_flag'] = 1
    PlayerPower[playerID][powerType .. '_energy_match_flag'] = 1
    PlayerPower[playerID][powerType .. '_energy_match_helper_flag'] = 1

end