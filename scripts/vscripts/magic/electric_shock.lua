require('shoot_init')
require('skill_operation')
function stepOne(keys)
    local caster = keys.caster
    local ability = keys.ability
    local skillPoint = ability:GetCursorPosition()
    --local speed = ability:GetSpecialValueFor("speed")

    local casterPoint = caster:GetAbsOrigin()
    local max_distance = ability:GetSpecialValueFor("max_distance")
    local direction = (skillPoint - casterPoint):Normalized()
    local shootPoint = casterPoint + max_distance * direction
    local shoot = CreateUnitByName(keys.unitModel, shootPoint, true, nil, nil, caster:GetTeam())
    creatSkillShootInit(keys,shoot,caster,max_distance,direction)
    --过滤掉增加施法距离的操作
	--shoot.max_distance_operation = max_distance
    --initDurationBuff(keys)

    local casterBuff = keys.modifier_caster_name
    ability:ApplyDataDrivenModifier(caster, caster, casterBuff, {Duration = flyDuration})

    local ability_a_name	= keys.ability_a_name
    local ability_b_name	= keys.ability_b_name
    caster:SwapAbilities( ability_a_name, ability_b_name, false, true )

    local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot)
    ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
	shoot.particleID = particleID
	EmitSoundOn(keys.soundCast, caster)


	local playerID = caster:GetPlayerID()
    PlayerPower[playerID]["electric_shock_a"] = shoot
    shoot:SetPlayerID(playerID)
    --moveShoot(keys, shoot, electricBallBoomCallBack, nil)
end

function stepTwo(keys)
    local caster = keys.caster
    local ability = keys.ability
    local skillPoint = ability:GetCursorPosition()
    --local speed = ability:GetSpecialValueFor("speed")

    local casterPoint = caster:GetAbsOrigin()
    local max_distance = ability:GetSpecialValueFor("max_distance")
    local direction = (skillPoint - casterPoint):Normalized()
    local shootPoint = casterPoint + max_distance * direction
    local shoot = CreateUnitByName(keys.unitModel, shootPoint, true, nil, nil, caster:GetTeam())
    creatSkillShootInit(keys,shoot,caster,max_distance,direction)
    --过滤掉增加施法距离的操作
	--shoot.max_distance_operation = max_distance
    initDurationBuff(keys)

    local casterBuff = keys.modifier_caster_name
    ability:ApplyDataDrivenModifier(caster, caster, casterBuff, {Duration = flyDuration})

    local ability_a_name	= keys.ability_a_name
    local ability_b_name	= keys.ability_b_name
    caster:SwapAbilities( ability_a_name, ability_b_name, true, false )

    local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot)
    ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
	shoot.particleID = particleID
	EmitSoundOn(keys.soundCast, caster)

    PlayerPower[playerID]["electric_shock_b"] = shoot
    shoot:SetPlayerID(playerID)
    --moveShoot(keys, shoot, electricBallBoomCallBack, nil)
end