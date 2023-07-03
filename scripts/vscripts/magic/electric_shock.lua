require('shoot_init')
require('skill_operation')
function stepOne(keys)
    local caster = keys.caster
    local ability = keys.ability
    local skillPoint = ability:GetCursorPosition()  
    local casterPoint = caster:GetAbsOrigin()
    local max_distance = ability:GetSpecialValueFor("max_distance")
    local playerID = caster:GetPlayerID()
    local AbilityLevel = keys.AbilityLevel
    local set_distance = getFinalValueOperation(playerID,max_distance,'range',AbilityLevel,nil)
    local direction = (skillPoint - casterPoint):Normalized()
    local shootPoint = casterPoint + set_distance * direction

	
    local shoot = CreateUnitByName(keys.unitModel, shootPoint, true, nil, nil, caster:GetTeam())
    local groundPos = GetGroundPosition(shootPoint, shoot)
    local shootPos = Vector(groundPos.x, groundPos.y, groundPos.z + 100)
    shoot:SetAbsOrigin(shootPos)
    creatSkillShootInit(keys,shoot,caster,max_distance,direction)
    shoot.speed = 0
    --过滤掉增加施法距离的操作
	--shoot.max_distance_operation = max_distance
    --initDurationBuff(keys)

    local casterBuff = keys.modifier_caster_syn_name
    ability:ApplyDataDrivenModifier(caster, caster, casterBuff, {Duration = 5})
    shoot.launchElectricShock = 0
    Timers:CreateTimer(5 ,function()
        --print("launchElectricShock:",shoot.launchElectricShock)
        if shoot.launchElectricShock == 0 and shoot.energy_point ~= 0 then
            initStageA(keys)
            shootSoundAndParticle(shoot, 'miss')
            shootKill(shoot)
        end
        return nil
    end)

    local timeCount = 0
    Timers:CreateTimer(0.1 ,function()
        if shoot.energy_point == 0 and shoot.launchElectricShock == 0 then
            initStage(keys)
            shootSoundAndParticle(shoot, 'miss')
            shootKill(shoot)
            return nil
        end
        timeCount = timeCount + 0.1
        if timeCount >= 5 then
            return nil
        end
        return 0.1
    end)

    local ability_a_name	= keys.ability_a_name
    local ability_b_name	= keys.ability_b_name
    caster:SwapAbilities( ability_a_name, ability_b_name, false, true )

    local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot)
    ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
	shoot.particleID = particleID
	EmitSoundOn(keys.soundCast, caster)


	
    PlayerPower[playerID]["electric_shock_a"] = shoot
    shoot.playerID = playerID
    --moveShoot(keys, shoot, electricBallBoomCallBack, nil)
end

function stepTwo(keys)
    local caster = keys.caster
    local ability = keys.ability
    local skillPoint = ability:GetCursorPosition()
    --local speed = ability:GetSpecialValueFor("speed")

    local casterPoint = caster:GetAbsOrigin()
    local max_distance = ability:GetSpecialValueFor("max_distance")
    local playerID = caster:GetPlayerID()
    local AbilityLevel = keys.AbilityLevel
    local set_distance = getFinalValueOperation(playerID,max_distance,'range',AbilityLevel,nil)
    local direction = (skillPoint - casterPoint):Normalized()
    local shootPoint = casterPoint + set_distance * direction
    local shoot = CreateUnitByName(keys.unitModel, shootPoint, true, nil, nil, caster:GetTeam())
    --creatSkillShootInit(keys,shoot,caster,max_distance,direction)

    --过滤掉增加施法距离的操作
	--shoot.max_distance_operation = max_distance
    initDurationBuff(keys)


    local ability_a_name	= keys.ability_a_name
    local ability_b_name	= keys.ability_b_name
    caster:SwapAbilities( ability_a_name, ability_b_name, true, false )

    local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot)
    ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
	shoot.particleID = particleID
	EmitSoundOn(keys.soundCast, caster)

    PlayerPower[playerID]["electric_shock_b"] = shoot
    shoot.playerID = playerID
    local shoot_a =  PlayerPower[playerID]["electric_shock_a"] 
    shoot_a.launchElectricShock = 1


    launchElectricShock(keys)
end

function launchElectricShock(keys)
    local caster = keys.caster
    local playerID = caster:GetPlayerID()

    local shoot_a = PlayerPower[playerID]["electric_shock_a"]
    local shoot_b = PlayerPower[playerID]["electric_shock_b"]

    local a_point = shoot_a:GetAbsOrigin()
    local b_point = shoot_b:GetAbsOrigin()

    local a_direction = (b_point - a_point):Normalized()
    local b_direction = (a_point - b_point):Normalized()

    local max_distance = (b_point - a_point):Length2D()

    creatSkillShootInit(keys,shoot_a,caster,max_distance,a_direction)
    creatSkillShootInit(keys,shoot_b,caster,max_distance,b_direction)
    shoot_b.isBoom = 1
    shoot_a.intervalCallBack = electricShockIntervalCallBack
    shoot_b.intervalCallBack = electricShockIntervalCallBack
    

    moveShoot(keys, shoot_a, nil, electricShockAHitCallback)
    moveShoot(keys, shoot_b, nil, electricShockBHitCallback)

    initStage(keys)
end

function electricShockAHitCallback(shoot,unit)
    local keys = shoot.keysTable
    local caster = keys.caster
	local playerID = caster:GetPlayerID()
	local ability = keys.ability
    local AbilityLevel = shoot.abilityLevel
    local debuffName = keys.stunDebuff
    local damage = getApplyDamageValue(shoot) / 4
    ApplyDamage({victim = unit, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType()})

    local debuffDuration = ability:GetSpecialValueFor("stun_debuff_duration") --debuff持续时间
    debuffDuration = getFinalValueOperation(playerID,debuffDuration,'control',AbilityLevel,nil)
    debuffDuration = getApplyControlValue(shoot, debuffDuration)
    debuffDuration = debuffDuration * (shoot.speed -200 * 0.02) / (800 * 0.02)
    --print("AdebuffDuration:",debuffDuration)
    ability:ApplyDataDrivenModifier(caster, unit, debuffName, {Duration = debuffDuration})
end

function electricShockBHitCallback(shoot,unit)
    local keys = shoot.keysTable
    local caster = keys.caster
	local playerID = caster:GetPlayerID()
	local ability = keys.ability
    local AbilityLevel = shoot.abilityLevel
    local debuffName = keys.sleepDebuff
    local damage = getApplyDamageValue(shoot) / 4
    ApplyDamage({victim = unit, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType()})

    local debuffDuration = ability:GetSpecialValueFor("sleep_debuff_duration") --debuff持续时间
    debuffDuration = getFinalValueOperation(playerID,debuffDuration,'control',AbilityLevel,nil)
    debuffDuration = getApplyControlValue(shoot, debuffDuration)
    debuffDuration = debuffDuration * (shoot.speed - 200 * 0.02) / (800 * 0.02)
    --print("BdebuffDuration:",debuffDuration)
    ability:ApplyDataDrivenModifier(caster, unit, debuffName, {Duration = debuffDuration})
end


function electricShockIntervalCallBack(shoot)
    local keys = shoot.keysTable
	local caster = keys.caster
    local playerID = caster:GetPlayerID()
    local interval = 0.02
    local shoot_a = PlayerPower[playerID]["electric_shock_a"]
    local shoot_b = PlayerPower[playerID]["electric_shock_b"]
    local energy_point_a = shoot_a.energy_point
    local energy_point_b = shoot_b.energy_point
    --print("electricShockIntervalCallBack-a",energy_point_a,"b:",energy_point_b)
    if energy_point_a == 0 and energy_point_b > 0 then
        shootSoundAndParticle(shoot_b, 'miss')
        shootKill(shoot_b)
    end
    if energy_point_b == 0 and energy_point_a > 0 then
        shootSoundAndParticle(shoot_a, 'miss')
        shootKill(shoot_a)
    end

	local ability = keys.ability
    --local debuff_aoe_radius = ability:GetSpecialValueFor("hit_range")
    local hit_range = ability:GetSpecialValueFor("hit_range")

    local a_position=shoot_a:GetAbsOrigin()
    local b_position=shoot_b:GetAbsOrigin()
    local distance = (b_position - a_position):Length2D() 
    local a_direction = (b_position - a_position):Normalized()
    shoot_a.direction = a_direction
    local b_direction = (a_position - b_position):Normalized()
    shoot_b.direction = b_direction
    --print("electricShockIntervalCallBack:",distance)
    local max_speed = 1000 * interval
    if shoot_a.speed < max_speed then 
        shoot_a.speed = shoot_a.speed + 800 * interval  / (1.5 / interval)
        shoot_b.speed = shoot_b.speed + 800 * interval / (1.5 / interval)
    end

    if shoot_b.distance_ab == nil then
        shoot_b.distance_ab = distance
    end
    --print("shoot.isBoom:",shoot.isBoom)
    if (distance < hit_range or distance > shoot_b.distance_ab) and shoot.isBoom == 1 then      
        electricShockBoomCallBack(shoot_b)
        shootKill(shoot_a)
    end
    shoot_b.distance_ab = distance
end


function electricShockBoomCallBack(shoot)
	electricShockBoomAOERenderParticles(shoot)
    boomAOEOperation(shoot, electricShockAOEOperationCallback)
end

function electricShockBoomAOERenderParticles(shoot)
    local keys = shoot.keysTable
	local caster = keys.caster
	--local ability = keys.ability
	local radius = shoot.aoe_radius--ability:GetSpecialValueFor("aoe_radius") 
	local particleBoom = ParticleManager:CreateParticle(keys.particles_boom, PATTACH_WORLDORIGIN, caster)
	local groundPos = GetGroundPosition(shoot:GetAbsOrigin(), shoot)
	ParticleManager:SetParticleControl(particleBoom, 0, groundPos)
	ParticleManager:SetParticleControl(particleBoom, 10, Vector(radius, 0, 0))
end

function electricShockAOEOperationCallback(shoot,unit)
    local keys = shoot.keysTable
    local caster = keys.caster
	local playerID = caster:GetPlayerID()
	local ability = keys.ability
    local AbilityLevel = shoot.abilityLevel
    local stunDebuff = keys.stunDebuff  
    local sleepDebuff = keys.sleepDebuff   

    local damage = getApplyDamageValue(shoot) / 2 
    ApplyDamage({victim = unit, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType()})

    local stunDebuffDuration = ability:GetSpecialValueFor("stun_debuff_duration")--debuff持续时间
    local sleepDebuffDuration = ability:GetSpecialValueFor("sleep_debuff_duration") 
    
    stunDebuffDuration = getFinalValueOperation(playerID,stunDebuffDuration,'control',AbilityLevel,nil)
    stunDebuffDuration = getApplyControlValue(shoot, stunDebuffDuration)

    sleepDebuffDuration = getFinalValueOperation(playerID,sleepDebuffDuration,'control',AbilityLevel,nil)
    sleepDebuffDuration = getApplyControlValue(shoot, sleepDebuffDuration)
    print("sleepDebuff:",sleepDebuff,"-",sleepDebuffDuration)
    ability:ApplyDataDrivenModifier(caster, unit, stunDebuff,  {Duration = stunDebuffDuration})
    ability:ApplyDataDrivenModifier(caster, unit, sleepDebuff, {Duration = sleepDebuffDuration})
    
    
end


function LevelUpAbility(keys)
    local caster = keys.caster
	local this_ability = keys.ability
	local this_abilityName = this_ability:GetAbilityName()
	local this_abilityLevel = this_ability:GetLevel()
	-- The ability to level up
	local ability_b_name = keys.ability_b_name
	local ability_handle = caster:FindAbilityByName(ability_b_name)
	local ability_level = ability_handle:GetLevel()
	-- Check to not enter a level up loop
	if ability_level ~= this_abilityLevel then
		ability_handle:SetLevel(this_abilityLevel)
	end
end

function initStage(keys)
    local caster	= keys.caster
	local ability	= keys.ability
--[[local pfx = caster.fire_spirits_pfx
	ParticleManager:DestroyParticle( pfx, false )
]]-- Swap main ability
    local ability_a_name	= ability:GetAbilityName()
    local ability_b_name	= keys.ability_b_name
    caster:SwapAbilities( ability_a_name, ability_b_name, true, false )
end

function initStageA(keys)
    local caster	= keys.caster
	local ability	= keys.ability
    local ability_b_name	= ability:GetAbilityName()
    local ability_a_name	= keys.ability_a_name
    caster:SwapAbilities( ability_a_name, ability_b_name, true, false )
end