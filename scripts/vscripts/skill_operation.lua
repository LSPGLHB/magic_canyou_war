require('player_power')
--LinkLuaModifier( "modifier_stone_beat_back_aoe_lua", "abilities/modifier_stone_beat_back_aoe_lua.lua",LUA_MODIFIER_MOTION_NONE )
----伤害相生增强计算(子弹实体)
function getApplyDamageValue(shoot)
	local damage = powerLevelOperation(shoot, 'damage', shoot.power_lv, shoot.damage) 
	if damage < 0 then
		damage = 1  --伤害保底
	end
	return damage
end
function getApplyControlValue(shoot, controlValue)
	local control = powerLevelOperation(shoot, 'control', shoot.power_lv, controlValue) 
	if control < 0 then
		control = 0.1  --伤害保底
	end
	return control
end
function getApplyEnergyValue(shoot, shootEnergy)
	local energy = powerLevelOperation(shoot, 'energy', shoot.power_lv, shootEnergy) 
	if energy < 0 then
		energy = 1  --伤害保底
	end
	return energy
end
--克制增强运算（依赖match_helper数值）
function powerLevelOperation(shoot, abilityName, powerLv, value)
	--print("powerLevelOperation",powerLv,"=",damage)
	local owner = shoot.owner
	local playerID = owner:GetPlayerID()
	local matchBuffName = abilityName..'_match'
	local matchValue = getFinalValueOperation(playerID,value,matchBuffName,shoot.abilityLevel,owner)
	--print(matchBuffName..':'..matchValue)
	--print("powerLevelOperation:"..#shoot.matchUnitsID)
	local helperBuffName = abilityName..'_match_helper'
	local matchHelperValue = matchValue
	for i = 1, #shoot.matchUnitsID do
		local valueID = shoot.matchUnitsID[i]
		local abilityLevel = shoot.matchAbilityLevel[i]
		--print("matchUnitsID:"..shoot.unit_type.."=="..valueID.."=="..abilityLevel)
		matchHelperValue = getFinalValueOperation(valueID,matchHelperValue,helperBuffName,abilityLevel,nil)
	end
	--print('matchHelperValue:'..matchHelperValue)
	if powerLv > 0 then
		value = matchHelperValue * 1.25
	end
	if powerLv < 0 then
		value = matchHelperValue * 0.75 
	end
	return value
end

--power_lv：标记增强等级
--power_flag: 标记是否实现增强效果
--加强削弱运算(被搜索目标实体，自身实体，aoe类型,是否敌对减弱否则加强)
function reinforceEach(unit,shoot,aoeType)
	local shootTeam = shoot:GetTeam()
	local shootOwner = shoot.owner
	local shootOwnerID = shootOwner:GetPlayerID()
	local shootLevel = shoot.abilityLevel
	local unitTeam = unit:GetTeam()
	local unitOwner = unit.owner
	--print("owner2",unit.owner)
	--print("owner3",unit:GetOwner())
	local unitOwnerID = unitOwner:GetPlayerID()
	local unitLevel = unit.abilityLevel

	local matchFlag = false
	local hostileFlag
	if shootTeam ~= unitTeam then
		hostileFlag = true
	else
		hostileFlag = false	
	end
	--获取触碰双方的属性
	local unitType = unit.unit_type
	local shootType
	if shoot ~= nil then
		shootType = shoot.unit_type
	end
	if aoeType ~=nil then
		shootType = aoeType
	end
	print("shoot-nuit-Type:",shootType,unitType)
	if shootType == "huo" then
		if hostileFlag then
			if unitType == "lei" then
				unit.power_lv =  unit.power_lv - 1
				unit.power_flag = 1
				--matchFlag = true
			end
		else
			if unitType == "tu" then
				unit.power_lv =  unit.power_lv + 1
				unit.power_flag = 1
				matchFlag = true
			end
		end
 	end
	if shootType == "feng" then
		if hostileFlag then
			if unitType == "tu" then
				unit.power_lv =  unit.power_lv - 1
				unit.power_flag = 1
				--matchFlag = true
			end
		else
			if unitType == "huo" then
				unit.power_lv =  unit.power_lv + 1
				unit.power_flag = 1
				matchFlag = true
			end
		end
	end
	if shootType == "shui" then
		if hostileFlag then
			if unitType == "huo" then
				unit.power_lv =  unit.power_lv - 1
				unit.power_flag = 1
				--matchFlag = true
			end
		else
			if unitType == "feng" then
				unit.power_lv =  unit.power_lv + 1
				unit.power_flag = 1
				matchFlag = true
			end
		end
	end
	if shootType == "lei" then
		if hostileFlag then
			if unitType == "feng" then
				unit.power_lv =  unit.power_lv - 1
				unit.power_flag = 1
				--matchFlag = true
			end
		else
			if unitType == "shui" then
				unit.power_lv =  unit.power_lv + 1
				unit.power_flag = 1
				matchFlag = true
			end
		end
	end
	if shootType == "tu" then
		if hostileFlag then
			if unitType == "shui" then
				unit.power_lv =  unit.power_lv - 1
				unit.power_flag = 1
				--matchFlag = true
			end
		else
			if unitType == "lei" then
				unit.power_lv =  unit.power_lv + 1
				unit.power_flag = 1
				matchFlag = true
			end
		end
	end
	if matchFlag then
		--不能所有都加，只有加强的才加，减弱的目前没加后续再看
		--加强伤害，控制等效果使用
		table.insert(unit.matchUnitsID,shootOwnerID)
		table.insert(unit.matchAbilityLevel,shootLevel)
		--魔魂需要现在加强
		local energyMatchBuffName = 'energy_match'
		local unitHealth = unit:GetHealth()
		local tempEnergy = getFinalValueOperation(unitOwnerID,unitHealth,energyMatchBuffName,unitLevel,unitOwner)
		unit.energy_match_bonus = getApplyEnergyValue(unit, tempEnergy) - tempEnergy

		if unit:HasModifier('modifier_health_debuff') then
			unit:RemoveModifierByName('modifier_health_debuff')
		end
		if unit:HasModifier('modifier_health_buff') then
			unit:RemoveModifierByName('modifier_health_buff')
		end
		unit:AddAbility('ability_health_control'):SetLevel(1)
		unit:RemoveModifierByName('modifier_health_debuff')
		unit:SetModifierStackCount('modifier_health_buff', unit, unit.energy_match_bonus)
		unit:RemoveAbility('ability_health_control')

		print("reinforceEachID:=="..shootOwnerID.."=="..shootLevel.."=="..#unit.matchUnitsID)
		print("energy_match_bonus:"..unit.energy_match_bonus)
	end
	--限制层数为1
	if unit.power_lv > 1 then
		unit.power_lv = 1
	end
	if unit.power_lv < -1 then
		unit.power_lv = -1
	end
end

--获得buff的能力，目前是测试物品lvxie用到
function setShootPower(caster, powerName, isAdd, value)
    initShootPower(caster)
    if( not isAdd ) then
        value = value * -1
    end
    if(powerName == "item_damage") then       
        caster.item_bonus_damage = caster.item_bonus_damage + value 
    end
    if(powerName == "item_shoot_speed") then       
        caster.item_bonus_shoot_speed = caster.item_bonus_shoot_speed + value 
    end 
end

--获得buff的能力，目前是测试物品lvxie用到
function getShootPower(caster, powerName)
    local value
    if(powerName == "item_damage") then       
        value = caster.item_bonus_damage
    end
    if(powerName == "item_shoot_speed") then    
        value = caster.item_bonus_shoot_speed
    end
    return value
end

function initShootPower(caster)
    if caster.item_bonus_damage == nil then
        caster.item_bonus_damage = 0
    end

    if caster.item_bonus_shoot_speed == nil then
        caster.item_bonus_shoot_speed = 0
    end
end

--技能加强或减弱粒子效果实现
function powerShootParticleOperation(keys,shoot,particleID)
	local new_particleID = particleID
	if shoot.power_lv > 0 and shoot.power_flag == 1 then
		Timers:CreateTimer(0.3,function ()
			ParticleManager:DestroyParticle(particleID, true)
			return nil
		end)
		new_particleID = ParticleManager:CreateParticle(keys.particles_power, PATTACH_ABSORIGIN_FOLLOW , shoot)
		ParticleManager:SetParticleControlEnt(new_particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
		shoot.power_flag = 0
	end
	if shoot.power_lv < 0 and shoot.power_flag == 1  then
		ParticleManager:DestroyParticle(particleID, true)
		new_particleID = ParticleManager:CreateParticle(keys.particles_weak, PATTACH_ABSORIGIN_FOLLOW , shoot)
		ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
		shoot.power_flag = 0
	end
	return new_particleID
end

--非AOE（简单的）子弹爆炸用
function shootBoomParticleOperation(shoot,destroyParticleID,showParticlesName,soundName,particlesDur)
	--消除子弹以及中弹粒子效果
	shoot:ForceKill(true)
	--中弹粒子效果
	ParticleManager:CreateParticle(showParticlesName, PATTACH_ABSORIGIN_FOLLOW, shoot)
	--中弹声音
	EmitSoundOn(soundName, shoot)
	--消除粒子效果
	if destroyParticleID then
		ParticleManager:DestroyParticle(destroyParticleID, true)
	end
	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("1"),function () shoot:AddNoDraw() end, particlesDur) --命中后动画持续时间
end

--击退单位处理
function shootPenetrateParticleOperation(keys,shoot)
	--中弹粒子效果
	ParticleManager:CreateParticle(keys.particles_hit, PATTACH_ABSORIGIN_FOLLOW, shoot) 
	--中弹声音
	EmitSoundOn(keys.sound_hit, shoot)
end






--影响弹道的buff
--测试速度调整
function skillSpeedOperation(keys,speed)
	local caster = keys.caster
	local ability = keys.ability
	local speed_up_per_stack = caster.speed_up_per_stack
	local item_bonus_shoot_speed = getShootPower(caster, "item_shoot_speed")--caster.item_bonus_shoot_speed
	if speed_up_per_stack == nil then
		speed_up_per_stack = 0
	end
	if item_bonus_shoot_speed == nil then
		item_bonus_shoot_speed = 0
	end
	local buff_modifier = "modifier_shoot_speed_up_buff"
	local speed_up_stacks = 0
	if caster:HasModifier(buff_modifier) then
		speed_up_stacks = caster:GetModifierStackCount(buff_modifier, ability)
	end
	local buff_speed_up = speed_up_stacks * speed_up_per_stack
	speed = (speed  + buff_speed_up  + item_bonus_shoot_speed) 
	return speed
end




