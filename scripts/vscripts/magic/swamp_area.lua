require('shoot_init')
require('skill_operation')
function createShoot(keys)
    local caster = keys.caster
    local ability = keys.ability
    local skillPoint = ability:GetCursorPosition()
    --local speed = ability:GetSpecialValueFor("speed")
    local aoe_radius = ability:GetSpecialValueFor("aoe_radius")
    local aoe_duration = ability:GetSpecialValueFor("aoe_duration")
    local casterPoint = caster:GetAbsOrigin()
    local max_distance = (skillPoint - casterPoint ):Length2D()
    local direction = (skillPoint - casterPoint):Normalized()
    local shoot = CreateUnitByName(keys.unitModel, casterPoint, true, nil, nil, caster:GetTeam())
    creatSkillShootInit(keys,shoot,caster,max_distance,direction)
    --过滤掉增加施法距离的操作
	shoot.max_distance_operation = max_distance
    initDurationBuff(keys)
    shoot.aoe_radius = aoe_radius
    shoot.aoe_duration = aoe_duration
    local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot)
    ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
    shoot.particleID = particleID
    EmitSoundOn(keys.soundCast, caster)
    moveShoot(keys, shoot, swampAreaBoomCallBack, nil)
end

function swampAreaBoomCallBack(shoot)
    local keys = shoot.keysTable
    swampAreaDuration(shoot) --实现持续光环效果以及粒子效果
    EmitSoundOn(keys.soundBoom, shoot)
end

function swampAreaDuration(shoot)
    local interval = 0.5
    swampAreaRenderParticles(shoot)
    durationAOEDamage(shoot, interval, swampAreaDamageCallback)
end

function swampAreaRenderParticles(shoot)
    local keys = shoot.keysTable
    local caster = keys.caster
	local ability = keys.ability

    local debuffDuration = ability:GetSpecialValueFor("debuff_duration") --debuff持续时间
    debuffDuration = getFinalValueOperation(playerID,debuffDuration,'control',AbilityLevel,owner)
    debuffDuration = getApplyControlValue(shoot, debuffDuration)

	local particleBoom = ParticleManager:CreateParticle(keys.particles_boom, PATTACH_WORLDORIGIN, caster)
    local groundPos = GetGroundPosition(shoot:GetAbsOrigin(), shoot)
	ParticleManager:SetParticleControl(particleBoom, 3, groundPos)
    ParticleManager:SetParticleControl(particleBoom, 10, Vector(shoot.aoe_radius, 0, 0))
    ParticleManager:SetParticleControl(particleBoom, 11, Vector(debuffDuration, 0, 0))
end

function swampAreaDamageCallback(shoot, unit, interval)
    local keys = shoot.keysTable
    local caster = keys.caster
    local shootPos = shoot:GetAbsOrigin()
    local unitPos = unit:GetAbsOrigin()
    local AbilityLevel = shoot.abilityLevel
    local radius = shoot.aoe_radius
    local ability = keys.ability
    local duration = shoot.aoe_duration
    local damageTotal = getApplyDamageValue(shoot)
    local damage = damageTotal / (duration / interval)

	ApplyDamage({victim = unit, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType()})

    local debuffDuration = ability:GetSpecialValueFor("debuff_duration") --debuff持续时间
    debuffDuration = getFinalValueOperation(playerID,debuffDuration,'control',AbilityLevel,owner)
    debuffDuration = getApplyControlValue(shoot, debuffDuration)

    ability:ApplyDataDrivenModifier(caster, unit, hitTargetDebuff, {Duration = debuffDuration})  
end