--永久类modifier
--装备，契约，神符，铭文临时等能力用
function setPlayerBuffByNameAndBValue(keys,buffName,baseValue)
    local hero = keys.caster
    local playerID = hero:GetPlayerID()
    if playerID == nil then
        playerID = hero.playerID
    end
    local modifierNameAdd
    local modifierNameRemove
    local abilityName = "ability_"..buffName.."_control"
    local modifierNameBuff = "modifier_"..buffName.."_buff"  
    local modifierNameDebuff = "modifier_"..buffName.."_debuff"
    local modifierStackCount =  getFinalValueOperation(playerID,baseValue,buffName,nil,'buffStack')
    --print("setPlayerBuffByAbilityAndModifier",buffName)
    --print("playerid:"..playerID)
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

--（范围用）
function setPlayerSimpleBuff(keys,buffName)
    local hero = keys.caster
    local playerID = hero:GetPlayerID()
    if playerID == nil then
        playerID = hero.playerID
    end
    local modifierNameAdd
    local modifierNameRemove
    local abilityName = "ability_"..buffName.."_control"
    local modifierNameBuff = "modifier_"..buffName.."_buff"  
    local modifierNameDebuff = "modifier_"..buffName.."_debuff"

    local modifierStackCount =  getSimpleValueOperation(playerID,buffName)
    if buffName == "cooldown_percent_final" then
        local cooldownPercentLimitReduce = getSimpleValueOperation(playerID,"cooldown_percent_limit_reduce")
        local cooldownPercentLimit = GameRules.cooldownPercentLimit + cooldownPercentLimitReduce
        if modifierStackCount > cooldownPercentLimit then
            modifierStackCount = cooldownPercentLimit
        end
    end
     
    --print("setPlayerBuffByAbilityAndModifier",buffName)
    --print("playerid:"..playerID)
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

--适用于没有基础值的属性（加强没有基础值的属性框架）
function getSimpleValueOperation(playerID,buffName)
    local abilityBuffName = buffName
    --固定增加能力专用（铭文与其他）
	local talentBonusValue = PlayerPower[playerID]['talent_'..abilityBuffName]
    --契约专用（固定能力）（有正负）
	local contractBonusValue = PlayerPower[playerID]['contract_'..abilityBuffName]
    --装备专用（非固定能力）
	local equipBonusValue = PlayerPower[playerID]['player_'..abilityBuffName]
    --单回合能力专用
	local tempBonusValue = PlayerPower[playerID]['temp_'..abilityBuffName] 
    --法阵神符专用（专用）
	--local battlefieldBonusValue = PlayerPower[playerID]['battlefield_'..abilityBuffName]

    local bonusValueTotal = contractBonusValue + equipBonusValue + talentBonusValue + tempBonusValue
	return bonusValueTotal
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
    if abilityLevel ~= nil and buffName == 'damage' then --只保留伤害分级，其他暂时撤销掉（2024.1.10）
        abilityBuffName = buffName.."_"..abilityLevel
    end

	--print("getFinalValueOperation"..playerID..abilityBuffName)
    --固定增加能力专用（铭文与其他）
    local talentpercentBase = PlayerPower[playerID]['talent_'..abilityBuffName..'_percent_base'] / 100
	local talentBonusValue = PlayerPower[playerID]['talent_'..abilityBuffName]
	local talentpercentFinal = PlayerPower[playerID]['talent_'..abilityBuffName..'_percent_final'] / 100

    --契约专用（固定能力）（有正负）
	local contractpercentBase = PlayerPower[playerID]['contract_'..abilityBuffName..'_percent_base'] / 100
	local contractBonusValue = PlayerPower[playerID]['contract_'..abilityBuffName]
	local contractpercentFinal = PlayerPower[playerID]['contract_'..abilityBuffName..'_percent_final'] / 100

    --装备专用（非固定能力）
	local equippercentBase = PlayerPower[playerID]['player_'..abilityBuffName..'_percent_base'] / 100
	local equipBonusValue = PlayerPower[playerID]['player_'..abilityBuffName]
	local equippercentFinal = PlayerPower[playerID]['player_'..abilityBuffName..'_percent_final'] / 100

    --单回合能力专用
	local temppercentBase = PlayerPower[playerID]['temp_'..abilityBuffName..'_percent_base'] / 100
	local tempBonusValue = PlayerPower[playerID]['temp_'..abilityBuffName]
	local temppercentFinal = PlayerPower[playerID]['temp_'..abilityBuffName..'_percent_final'] / 100
    
    --法阵神符专用（专用）
    --[[
	local battlefieldpercentBase = PlayerPower[playerID]['battlefield_'..abilityBuffName..'_percent_base'] / 100
	local battlefieldBonusValue = PlayerPower[playerID]['battlefield_'..abilityBuffName]
	local battlefieldpercentFinal = PlayerPower[playerID]['battlefield_'..abilityBuffName..'_percent_final'] / 100
    ]]
	
	local flag = PlayerPower[playerID]['contract_'..buffName..'_flag']
    --print(flag)
    --装备不受加强的契约使用
    if (equippercentBase > 0) then
        equippercentBase = equippercentBase * flag
    end
    if (equipBonusValue > 0) then
        equipBonusValue = equipBonusValue * flag
    end
    if (equippercentFinal > 0) then
        equippercentFinal = equippercentFinal * flag
    end

    local percentBaseTotal =  contractpercentBase + equippercentBase + talentpercentBase + temppercentBase
    local bonusValueTotal = contractBonusValue + equipBonusValue + talentBonusValue + tempBonusValue
    local percentFinalTotal = contractpercentFinal + equippercentFinal + talentpercentFinal + temppercentFinal

	local operationValue =  (baseValue * (1 + percentBaseTotal ) + bonusValueTotal) * (1 + percentFinalTotal)

    if type == 'buffStack' then
        operationValue  =  operationValue - baseValue
    end
    --print("getFinalValueOperation:"..buffName)
	--print(equippercentBase..","..equipBonusValue..","..equippercentFinal)
    --print(operationValue)

	return operationValue
end

--基础属性数据包
function initPlayerPower()
    PlayerPower={}
    for playerID = 0, 13 do --10个玩家的数据包
        PlayerPower[playerID] = {} 
        local talentType = "talent" --铭文和（其他局内能力：好像暂时没其他能力）
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
        --local battlefieldType = "battlefield" --法阵临时
        initPlayerPowerOPeration(playerID,tempType)
        --initPlayerPowerOPeration(playerID,battlefieldType)
    end
end


--用于回合重置能力
function initTempPlayerPower()
    for playerID = 0, 12 do --10个玩家的数据包   
        if PlayerResource:GetConnectionState(playerID) ~= DOTA_CONNECTION_STATE_UNKNOWN then 
             --用于记录正负电击的两个电极子弹
            PlayerPower[playerID]["electric_shock_a"] = nil
            PlayerPower[playerID]["electric_shock_b"] = nil
            --print("removeremove",playerID)
            local hero = PlayerResource:GetSelectedHeroEntity(playerID)
            --法阵神符
            --removeBattlefieldBuff(hero)
            --装备临时能力
            removeTempBuff(hero)
        end
    end
end

--用于计算是否技能施放完成，应用于下一发技能加强
function powerUpAbilityCount(unit, modifierName, shootCount, funcA, funcB) 
    unit.shootOver = 0
    Timers:CreateTimer(function()
        if unit.shootOver == 1 then
            shootCount = shootCount - 1
            unit:SetModifierStackCount(modifierName, unit, shootCount)
            if shootCount <= 0 and unit.shootOver == 1 then
                unit.shootOver = 0
                unit:RemoveModifierByName(modifierName)
                --return nil
            end
            if funcA ~= nil then
                funcA(unit)
            end
            
            return nil
        end
        --用于不算加强技能的技能
        if unit.shootOver == -1 then
            if funcB ~= nil then
                funcB(unit)
            end
            return nil
        end
        return 0.02
    end)
end

--获取冷却缩减后的充能时间(弃用！)
function getCooldownChargeReplenish(playerID,charge_replenish_time)
    local cooldown = getFinalValueOperation(playerID,0,'cooldown',nil,nil)
    --print("cooldown:"..cooldown)
	if cooldown >= 100 then
		cooldown = 95
	end
	charge_replenish_time = charge_replenish_time * (1 - cooldown / 100)
    return charge_replenish_time
end


--"battlefield_mana_regen_buff_datadriven"
--移除法阵神符能力
--[[
function removeBattlefieldBuff(hero)
    removePlayerBuffByAbilityAndModifier(hero, "battlefield_health_buff_datadriven", "modifier_battlefield_health_buff_datadriven","nil")
    removePlayerBuffByAbilityAndModifier(hero, "battlefield_vision_buff_datadriven", "modifier_battlefield_vision_buff_datadriven","nil")
    removePlayerBuffByAbilityAndModifier(hero, "battlefield_speed_buff_datadriven", "modifier_battlefield_speed_buff_datadriven","nil")
    removePlayerBuffByAbilityAndModifier(hero, "battlefield_mana_buff_datadriven", "modifier_battlefield_mana_buff_datadriven","nil")
    removePlayerBuffByAbilityAndModifier(hero, "battlefield_mana_regen_buff_datadriven", "modifier_battlefield_mana_regen_buff_datadriven","nil")
end]]

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
    PlayerPower[playerID][powerType .. '_vision_percent_base'] = 0
    PlayerPower[playerID][powerType .. '_vision_percent_final'] = 0

    PlayerPower[playerID][powerType .. '_speed'] = 0
    PlayerPower[playerID][powerType .. '_speed_percent_base'] = 0
    PlayerPower[playerID][powerType .. '_speed_percent_final'] = 0 
    
    PlayerPower[playerID][powerType .. '_health'] = 0     
    PlayerPower[playerID][powerType .. '_health_percent_base'] = 0
    PlayerPower[playerID][powerType .. '_health_percent_final'] = 0 
    
    PlayerPower[playerID][powerType .. '_mana'] = 0     
    PlayerPower[playerID][powerType .. '_mana_percent_base'] = 0
    PlayerPower[playerID][powerType .. '_mana_percent_final'] = 0
    
    PlayerPower[playerID][powerType .. '_mana_regen'] = 0
    PlayerPower[playerID][powerType .. '_mana_regen_percent_base'] = 0
    PlayerPower[playerID][powerType .. '_mana_regen_percent_final'] = 0

    PlayerPower[playerID][powerType .. '_defense'] = 0     
    PlayerPower[playerID][powerType .. '_defense_percent_base'] = 0
    PlayerPower[playerID][powerType .. '_defense_percent_final'] = 0

    PlayerPower[playerID][powerType .. '_cooldown'] = 0
    PlayerPower[playerID][powerType .. '_cooldown_percent_base'] = 0
    PlayerPower[playerID][powerType .. '_cooldown_percent_final'] = 0
    PlayerPower[playerID][powerType .. '_cooldown_percent_limit_reduce'] = 0

    PlayerPower[playerID][powerType .. '_range'] = 0
    PlayerPower[playerID][powerType .. '_range_percent_base'] = 0
    PlayerPower[playerID][powerType .. '_range_percent_final'] = 0

    PlayerPower[playerID][powerType .. '_radius'] = 0
    PlayerPower[playerID][powerType .. '_radius_percent_base'] = 0
    PlayerPower[playerID][powerType .. '_radius_percent_final'] = 0

    PlayerPower[playerID][powerType .. '_ability_speed'] = 0
    PlayerPower[playerID][powerType .. '_ability_speed_percent_base'] = 0
    PlayerPower[playerID][powerType .. '_ability_speed_percent_final'] = 0

    PlayerPower[playerID][powerType .. '_mana_cost'] = 0
    PlayerPower[playerID][powerType .. '_mana_cost_percent_base'] = 0
    PlayerPower[playerID][powerType .. '_mana_cost_percent_final'] = 0

    PlayerPower[playerID][powerType .. '_match'] = 0
    PlayerPower[playerID][powerType .. '_match_percent_base'] = 0
    PlayerPower[playerID][powerType .. '_match_percent_final'] = 0

    PlayerPower[playerID][powerType .. '_match_helper'] = 0
    PlayerPower[playerID][powerType .. '_match_helper_percent_base'] = 0
    PlayerPower[playerID][powerType .. '_match_helper_percent_final'] = 0

    PlayerPower[playerID][powerType .. '_control'] = 0
    PlayerPower[playerID][powerType .. '_control_percent_base'] = 0
    PlayerPower[playerID][powerType .. '_control_percent_final'] = 0

    PlayerPower[playerID][powerType .. '_energy'] = 0
    PlayerPower[playerID][powerType .. '_energy_percent_base'] = 0
    PlayerPower[playerID][powerType .. '_energy_percent_final'] = 0

    PlayerPower[playerID][powerType .. '_damage_d'] = 0
    PlayerPower[playerID][powerType .. '_damage_d_percent_base'] = 0
    PlayerPower[playerID][powerType .. '_damage_d_percent_final'] = 0
    PlayerPower[playerID][powerType .. '_damage_c'] = 0
    PlayerPower[playerID][powerType .. '_damage_c_percent_base'] = 0
    PlayerPower[playerID][powerType .. '_damage_c_percent_final'] = 0
    PlayerPower[playerID][powerType .. '_damage_b'] = 0
    PlayerPower[playerID][powerType .. '_damage_b_percent_base'] = 0
    PlayerPower[playerID][powerType .. '_damage_b_percent_final'] = 0
    PlayerPower[playerID][powerType .. '_damage_a'] = 0
    PlayerPower[playerID][powerType .. '_damage_a_percent_base'] = 0
    PlayerPower[playerID][powerType .. '_damage_a_percent_final'] = 0

    --技能能力
    --[[
    PlayerPower[playerID][powerType .. '_ability_speed_d'] = 0
    PlayerPower[playerID][powerType .. '_ability_speed_d_percent_base'] = 0
    PlayerPower[playerID][powerType .. '_ability_speed_d_percent_final'] = 0
    PlayerPower[playerID][powerType .. '_ability_speed_c'] = 0
    PlayerPower[playerID][powerType .. '_ability_speed_c_percent_base'] = 0
    PlayerPower[playerID][powerType .. '_ability_speed_c_percent_final'] = 0
    PlayerPower[playerID][powerType .. '_ability_speed_b'] = 0
    PlayerPower[playerID][powerType .. '_ability_speed_b_percent_base'] = 0
    PlayerPower[playerID][powerType .. '_ability_speed_b_percent_final'] = 0
    PlayerPower[playerID][powerType .. '_ability_speed_a'] = 0
    PlayerPower[playerID][powerType .. '_ability_speed_a_percent_base'] = 0
    PlayerPower[playerID][powerType .. '_ability_speed_a_percent_final'] = 0

    PlayerPower[playerID][powerType .. '_range_d'] = 0
    PlayerPower[playerID][powerType .. '_range_d_percent_base'] = 0
    PlayerPower[playerID][powerType .. '_range_d_percent_final'] = 0
    PlayerPower[playerID][powerType .. '_range_c'] = 0
    PlayerPower[playerID][powerType .. '_range_c_percent_base'] = 0
    PlayerPower[playerID][powerType .. '_range_c_percent_final'] = 0
    PlayerPower[playerID][powerType .. '_range_b'] = 0
    PlayerPower[playerID][powerType .. '_range_b_percent_base'] = 0
    PlayerPower[playerID][powerType .. '_range_b_percent_final'] = 0
    PlayerPower[playerID][powerType .. '_range_a'] = 0
    PlayerPower[playerID][powerType .. '_range_a_percent_base'] = 0
    PlayerPower[playerID][powerType .. '_range_a_percent_final'] = 0

    PlayerPower[playerID][powerType .. '_radius_d'] = 0
    PlayerPower[playerID][powerType .. '_radius_d_percent_base'] = 0
    PlayerPower[playerID][powerType .. '_radius_d_percent_final'] = 0
    PlayerPower[playerID][powerType .. '_radius_c'] = 0
    PlayerPower[playerID][powerType .. '_radius_c_percent_base'] = 0
    PlayerPower[playerID][powerType .. '_radius_c_percent_final'] = 0
    PlayerPower[playerID][powerType .. '_radius_b'] = 0
    PlayerPower[playerID][powerType .. '_radius_b_percent_base'] = 0
    PlayerPower[playerID][powerType .. '_radius_b_percent_final'] = 0
    PlayerPower[playerID][powerType .. '_radius_a'] = 0
    PlayerPower[playerID][powerType .. '_radius_a_percent_base'] = 0
    PlayerPower[playerID][powerType .. '_radius_a_percent_final'] = 0

    PlayerPower[playerID][powerType .. '_mana_cost_d'] = 0
    PlayerPower[playerID][powerType .. '_mana_cost_d_percent_base'] = 0
    PlayerPower[playerID][powerType .. '_mana_cost_d_percent_final'] = 0
    PlayerPower[playerID][powerType .. '_mana_cost_c'] = 0
    PlayerPower[playerID][powerType .. '_mana_cost_c_percent_base'] = 0
    PlayerPower[playerID][powerType .. '_mana_cost_c_percent_final'] = 0
    PlayerPower[playerID][powerType .. '_mana_cost_b'] = 0
    PlayerPower[playerID][powerType .. '_mana_cost_b_percent_base'] = 0
    PlayerPower[playerID][powerType .. '_mana_cost_b_percent_final'] = 0
    PlayerPower[playerID][powerType .. '_mana_cost_a'] = 0
    PlayerPower[playerID][powerType .. '_mana_cost_a_percent_base'] = 0
    PlayerPower[playerID][powerType .. '_mana_cost_a_percent_final'] = 0

    PlayerPower[playerID][powerType .. '_damage_d'] = 0
    PlayerPower[playerID][powerType .. '_damage_d_percent_base'] = 0
    PlayerPower[playerID][powerType .. '_damage_d_percent_final'] = 0
    PlayerPower[playerID][powerType .. '_damage_c'] = 0
    PlayerPower[playerID][powerType .. '_damage_c_percent_base'] = 0
    PlayerPower[playerID][powerType .. '_damage_c_percent_final'] = 0
    PlayerPower[playerID][powerType .. '_damage_b'] = 0
    PlayerPower[playerID][powerType .. '_damage_b_percent_base'] = 0
    PlayerPower[playerID][powerType .. '_damage_b_percent_final'] = 0
    PlayerPower[playerID][powerType .. '_damage_a'] = 0
    PlayerPower[playerID][powerType .. '_damage_a_percent_base'] = 0
    PlayerPower[playerID][powerType .. '_damage_a_percent_final'] = 0

    PlayerPower[playerID][powerType .. '_damage_match_d'] = 0
    PlayerPower[playerID][powerType .. '_damage_match_d_percent_base'] = 0
    PlayerPower[playerID][powerType .. '_damage_match_d_percent_final'] = 0
    PlayerPower[playerID][powerType .. '_damage_match_c'] = 0
    PlayerPower[playerID][powerType .. '_damage_match_c_percent_base'] = 0
    PlayerPower[playerID][powerType .. '_damage_match_c_percent_final'] = 0
    PlayerPower[playerID][powerType .. '_damage_match_b'] = 0
    PlayerPower[playerID][powerType .. '_damage_match_b_percent_base'] = 0
    PlayerPower[playerID][powerType .. '_damage_match_b_percent_final'] = 0
    PlayerPower[playerID][powerType .. '_damage_match_a'] = 0
    PlayerPower[playerID][powerType .. '_damage_match_a_percent_base'] = 0
    PlayerPower[playerID][powerType .. '_damage_match_a_percent_final'] = 0

    PlayerPower[playerID][powerType .. '_damage_match_helper_d'] = 0
    PlayerPower[playerID][powerType .. '_damage_match_helper_d_percent_base'] = 0
    PlayerPower[playerID][powerType .. '_damage_match_helper_d_percent_final'] = 0
    PlayerPower[playerID][powerType .. '_damage_match_helper_c'] = 0
    PlayerPower[playerID][powerType .. '_damage_match_helper_c_percent_base'] = 0
    PlayerPower[playerID][powerType .. '_damage_match_helper_c_percent_final'] = 0
    PlayerPower[playerID][powerType .. '_damage_match_helper_b'] = 0
    PlayerPower[playerID][powerType .. '_damage_match_helper_b_percent_base'] = 0
    PlayerPower[playerID][powerType .. '_damage_match_helper_b_percent_final'] = 0
    PlayerPower[playerID][powerType .. '_damage_match_helper_a'] = 0
    PlayerPower[playerID][powerType .. '_damage_match_helper_a_percent_base'] = 0
    PlayerPower[playerID][powerType .. '_damage_match_helper_a_percent_final'] = 0

    PlayerPower[playerID][powerType .. '_control_d'] = 0
    PlayerPower[playerID][powerType .. '_control_d_percent_base'] = 0
    PlayerPower[playerID][powerType .. '_control_d_percent_final'] = 0
    PlayerPower[playerID][powerType .. '_control_c'] = 0
    PlayerPower[playerID][powerType .. '_control_c_percent_base'] = 0
    PlayerPower[playerID][powerType .. '_control_c_percent_final'] = 0
    PlayerPower[playerID][powerType .. '_control_b'] = 0
    PlayerPower[playerID][powerType .. '_control_b_percent_base'] = 0
    PlayerPower[playerID][powerType .. '_control_b_percent_final'] = 0
    PlayerPower[playerID][powerType .. '_control_a'] = 0
    PlayerPower[playerID][powerType .. '_control_a_percent_base'] = 0
    PlayerPower[playerID][powerType .. '_control_a_percent_final'] = 0

    PlayerPower[playerID][powerType .. '_control_match_d'] = 0
    PlayerPower[playerID][powerType .. '_control_match_d_percent_base'] = 0
    PlayerPower[playerID][powerType .. '_control_match_d_percent_final'] = 0
    PlayerPower[playerID][powerType .. '_control_match_c'] = 0
    PlayerPower[playerID][powerType .. '_control_match_c_percent_base'] = 0
    PlayerPower[playerID][powerType .. '_control_match_c_percent_final'] = 0
    PlayerPower[playerID][powerType .. '_control_match_b'] = 0
    PlayerPower[playerID][powerType .. '_control_match_b_percent_base'] = 0
    PlayerPower[playerID][powerType .. '_control_match_b_percent_final'] = 0
    PlayerPower[playerID][powerType .. '_control_match_a'] = 0
    PlayerPower[playerID][powerType .. '_control_match_a_percent_base'] = 0
    PlayerPower[playerID][powerType .. '_control_match_a_percent_final'] = 0

    PlayerPower[playerID][powerType .. '_control_match_helper_d'] = 0
    PlayerPower[playerID][powerType .. '_control_match_helper_d_percent_base'] = 0
    PlayerPower[playerID][powerType .. '_control_match_helper_d_percent_final'] = 0
    PlayerPower[playerID][powerType .. '_control_match_helper_c'] = 0
    PlayerPower[playerID][powerType .. '_control_match_helper_c_percent_base'] = 0
    PlayerPower[playerID][powerType .. '_control_match_helper_c_percent_final'] = 0
    PlayerPower[playerID][powerType .. '_control_match_helper_b'] = 0
    PlayerPower[playerID][powerType .. '_control_match_helper_b_percent_base'] = 0
    PlayerPower[playerID][powerType .. '_control_match_helper_b_percent_final'] = 0
    PlayerPower[playerID][powerType .. '_control_match_helper_a'] = 0
    PlayerPower[playerID][powerType .. '_control_match_helper_a_percent_base'] = 0
    PlayerPower[playerID][powerType .. '_control_match_helper_a_percent_final'] = 0
    
    PlayerPower[playerID][powerType .. '_energy_d'] = 0
    PlayerPower[playerID][powerType .. '_energy_d_percent_base'] = 0
    PlayerPower[playerID][powerType .. '_energy_d_percent_final'] = 0
    PlayerPower[playerID][powerType .. '_energy_c'] = 0
    PlayerPower[playerID][powerType .. '_energy_c_percent_base'] = 0
    PlayerPower[playerID][powerType .. '_energy_c_percent_final'] = 0
    PlayerPower[playerID][powerType .. '_energy_b'] = 0
    PlayerPower[playerID][powerType .. '_energy_b_percent_base'] = 0
    PlayerPower[playerID][powerType .. '_energy_b_percent_final'] = 0
    PlayerPower[playerID][powerType .. '_energy_a'] = 0
    PlayerPower[playerID][powerType .. '_energy_a_percent_base'] = 0
    PlayerPower[playerID][powerType .. '_energy_a_percent_final'] = 0

    PlayerPower[playerID][powerType .. '_energy_match_d'] = 0
    PlayerPower[playerID][powerType .. '_energy_match_d_percent_base'] = 0
    PlayerPower[playerID][powerType .. '_energy_match_d_percent_final'] = 0
    PlayerPower[playerID][powerType .. '_energy_match_c'] = 0
    PlayerPower[playerID][powerType .. '_energy_match_c_percent_base'] = 0
    PlayerPower[playerID][powerType .. '_energy_match_c_percent_final'] = 0
    PlayerPower[playerID][powerType .. '_energy_match_b'] = 0
    PlayerPower[playerID][powerType .. '_energy_match_b_percent_base'] = 0
    PlayerPower[playerID][powerType .. '_energy_match_b_percent_final'] = 0
    PlayerPower[playerID][powerType .. '_energy_match_a'] = 0
    PlayerPower[playerID][powerType .. '_energy_match_a_percent_base'] = 0
    PlayerPower[playerID][powerType .. '_energy_match_a_percent_final'] = 0

    PlayerPower[playerID][powerType .. '_energy_match_helper_d'] = 0
    PlayerPower[playerID][powerType .. '_energy_match_helper_d_percent_base'] = 0
    PlayerPower[playerID][powerType .. '_energy_match_helper_d_percent_final'] = 0
    PlayerPower[playerID][powerType .. '_energy_match_helper_c'] = 0
    PlayerPower[playerID][powerType .. '_energy_match_helper_c_percent_base'] = 0
    PlayerPower[playerID][powerType .. '_energy_match_helper_c_percent_final'] = 0
    PlayerPower[playerID][powerType .. '_energy_match_helper_b'] = 0
    PlayerPower[playerID][powerType .. '_energy_match_helper_b_percent_base'] = 0
    PlayerPower[playerID][powerType .. '_energy_match_helper_b_percent_final'] = 0
    PlayerPower[playerID][powerType .. '_energy_match_helper_a'] = 0
    PlayerPower[playerID][powerType .. '_energy_match_helper_a_percent_base'] = 0
    PlayerPower[playerID][powerType .. '_energy_match_helper_a_percent_final'] = 0
    ]]
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