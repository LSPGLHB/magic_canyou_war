require('shoot_init')
require('skill_operation')
function createFireBottle(keys)
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
    moveShoot(keys, shoot, fireBottleBoomCallBack, nil)
end

function fireBottleBoomCallBack(shoot)
    local keys = shoot.keysTable
    fireBottleDuration(shoot) --实现持续光环效果以及粒子效果
    EmitSoundOn(keys.soundBoom, shoot)
end

function fireBottleDuration(shoot)
    local interval = 0.5
    fireBottleRenderParticles(shoot)
    durationAOEDamage(shoot, interval, fireBottleDamageCallback)
end

function fireBottleRenderParticles(shoot)
    local keys = shoot.keysTable
    local caster = keys.caster
	--local ability = keys.ability
	local particleBoom = ParticleManager:CreateParticle(keys.particles_boom, PATTACH_WORLDORIGIN, caster)
    local groundPos = GetGroundPosition(shoot:GetAbsOrigin(), shoot)
	ParticleManager:SetParticleControl(particleBoom, 3, groundPos)
    ParticleManager:SetParticleControl(particleBoom, 10, Vector(shoot.aoe_radius, 1, 0))
    ParticleManager:SetParticleControl(particleBoom, 11, Vector(shoot.aoe_duration, 0, 0))
end

function fireBottleDamageCallback(shoot, unit, interval)
    local keys = shoot.keysTable
    local caster = keys.caster
    local shootPos = shoot:GetAbsOrigin()
    local unitPos = unit:GetAbsOrigin()
    local radius = shoot.aoe_radius
    local ability = keys.ability
    local duration = shoot.aoe_duration
    local damageTotal = getApplyDamageValue(shoot)
    local damage = damageTotal / (duration / interval)
    local distance = (shootPos - unitPos):Length2D()
    if distance < 0.5 * radius then
        damage = damage * 2
    end
	ApplyDamage({victim = unit, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType()})
end