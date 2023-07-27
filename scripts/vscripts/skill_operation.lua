require('player_power')
----伤害相生增强计算(子弹实体)
function getApplyDamageValue(shoot)
	local damage = powerLevelOperation(shoot, 'damage', shoot.power_lv, shoot.damage) 
	if damage < 0 then
		damage = 0  --伤害保底
	end
	return damage
end
function getApplyControlValue(shoot, controlValue)
	local control = powerLevelOperation(shoot, 'control', shoot.power_lv, controlValue) 
	if control <= 0 then
		control = 0.1  --伤害保底
	end
	return control
end
function getApplyEnergyValue(shoot, shootEnergy, flag)
	local powerLv
	if flag then
		powerLv = 1
	else
		powerLv = -1
	end
	local energy = powerLevelOperation(shoot, 'energy', powerLv, shootEnergy) 
	if energy <= 0 then
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
		matchHelperValue = getFinalValueOperation(valueID,matchHelperValue,helperBuffName,abilityLevel,owner)
	end
	--print('matchHelperValue:'..matchHelperValue)
	if powerLv > 0 then
		value = matchHelperValue * 1.25
	end
	if powerLv < 0 then
		value = matchHelperValue * 0.75 
	end
	--print("powerLevelOperationval:",value)
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

	local powerSound
	local matchFlag = false
	local restrainFlag = false
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
		if hostileFlag then  --注释部分是区分是否同一队伍，用于加强削弱区分
			if unitType == "shui" and shoot.power_lv > -1 then
				shoot.power_lv =  shoot.power_lv - 1
				shoot.power_flag = 1
				restrainFlag = true
				powerSound = shoot.soundWeak
			end
		else
			if unitType == "feng" and shoot.power_lv < 1 then
				shoot.power_lv =  shoot.power_lv + 1
				shoot.power_flag = 1
				matchFlag = true
				powerSound = shoot.soundPower
			end
		end
 	end
	if shootType == "feng" then
		if hostileFlag then
			if unitType == "lei" and shoot.power_lv > -1 then
				shoot.power_lv =  shoot.power_lv - 1
				shoot.power_flag = 1
				restrainFlag = true
				powerSound = shoot.soundWeak
			end
		else
			if unitType == "shui" and shoot.power_lv < 1 then
				shoot.power_lv =  shoot.power_lv + 1
				shoot.power_flag = 1
				matchFlag = true
				powerSound = shoot.soundPower
			end
		end
	end
	if shootType == "shui" then
		if hostileFlag then
			if unitType == "tu" and shoot.power_lv > -1 then
				shoot.power_lv =  shoot.power_lv - 1
				shoot.power_flag = 1	
				restrainFlag = true
				powerSound = shoot.soundWeak
			end
		else
			if unitType == "lei" and shoot.power_lv < 1 then
				shoot.power_lv =  shoot.power_lv + 1
				shoot.power_flag = 1
				matchFlag = true
				powerSound = shoot.soundPower
			end
		end
	end
	if shootType == "lei" then
		if hostileFlag then
			if unitType == "huo" and shoot.power_lv > -1 then
				shoot.power_lv =  shoot.power_lv - 1
				shoot.power_flag = 1
				restrainFlag = true
				powerSound = shoot.soundWeak
			end
		else
			if unitType == "tu" and shoot.power_lv < 1 then
				shoot.power_lv =  shoot.power_lv + 1
				shoot.power_flag = 1
				matchFlag = true
				powerSound = shoot.soundPower
			end
		end
	end
	if shootType == "tu" then
		if hostileFlag then
			if unitType == "feng" and shoot.power_lv > -1 then
				shoot.power_lv =  shoot.power_lv - 1
				shoot.power_flag = 1
				restrainFlag = true
				powerSound = shoot.soundWeak
			end
		else
			if unitType == "huo" and shoot.power_lv < 1 then
				shoot.power_lv =  shoot.power_lv + 1
				shoot.power_flag = 1
				matchFlag = true
				powerSound = shoot.soundPower
			end
		end
	end

	if matchFlag or restrainFlag then
		

	end
	
	--如果被增强
	if matchFlag  then
		--不能所有都加，只有加强的才加，减弱的目前没加后续，再看
		--加强伤害，控制等效果使用
		EmitSoundOn(powerSound, shoot)
		table.insert(shoot.matchUnitsID,shootOwnerID)
		table.insert(shoot.matchAbilityLevel,shootLevel)

		--魔魂加强
		local shootEnergy = shoot:GetMaxHealth()
		shoot.energy_point = getApplyEnergyValue(shoot, shootEnergy, true) - shootEnergy + shoot.energy_point

	end

	--如果被克制
	if restrainFlag then
		--魔魂相克减弱
		local shootEnergy = shoot:GetMaxHealth()
		shoot.energy_point = getApplyEnergyValue(shoot, shootEnergy, false) - shootEnergy + shoot.energy_point
		EmitSoundOn(powerSound, shoot)
	end

	
	--限制层数为1,目前已经肯定不进流程
	--[[
	if shoot.power_lv > 1 then
		shoot.power_lv = 1			
	end
	if shoot.power_lv < -1 then
		shoot.power_lv = -1
	end]]
end

--技能加强或减弱粒子效果实现
function powerShootParticleOperation(keys,shoot)
	local new_particleID = shoot.particleID
	local particleID = shoot.particleID
	--print("power_lv:",shoot.power_lv,shoot.power_flag)
	if shoot.power_lv > 0 and shoot.power_flag == 1 then
		Timers:CreateTimer(0.3,function ()
			ParticleManager:DestroyParticle(particleID, true)
			return nil
		end)
		new_particleID = ParticleManager:CreateParticle(shoot.particles_power, PATTACH_ABSORIGIN_FOLLOW , shoot)
		ParticleManager:SetParticleControlEnt(new_particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
		shoot.power_flag = 0
	end
	if shoot.power_lv == 0 and shoot.power_flag == 1 then
		Timers:CreateTimer(0.3,function ()
			ParticleManager:DestroyParticle(particleID, true)
			return nil
		end)
		new_particleID = ParticleManager:CreateParticle(shoot.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot)
		ParticleManager:SetParticleControlEnt(new_particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
		shoot.power_flag = 0
	end
	if shoot.power_lv < 0 and shoot.power_flag == 1  then
		Timers:CreateTimer(0.3,function ()
			ParticleManager:DestroyParticle(particleID, true)
			return nil
		end)
		new_particleID = ParticleManager:CreateParticle(shoot.particles_weak, PATTACH_ABSORIGIN_FOLLOW , shoot)
		ParticleManager:SetParticleControlEnt(new_particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
		shoot.power_flag = 0
	end
	shoot.particleID = new_particleID
end







