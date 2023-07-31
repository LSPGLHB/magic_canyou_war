require('shoot_init')
require('skill_operation')
function createShoot(keys)
    local caster = keys.caster
    local ability = keys.ability
    local skillPoint = ability:GetCursorPosition()
    local aoe_radius = ability:GetSpecialValueFor("aoe_radius")
    local casterPoint = caster:GetAbsOrigin()
    local max_distance = (skillPoint - casterPoint ):Length2D()
    local direction = (skillPoint - casterPoint):Normalized()
    local shoot = CreateUnitByName(keys.unitModel, casterPoint, true, nil, nil, caster:GetTeam())
    creatSkillShootInit(keys,shoot,caster,max_distance,direction)
    --过滤掉增加施法距离的操作
	shoot.max_distance_operation = max_distance
    initDurationBuff(keys)
    shoot.aoe_radius = aoe_radius
    local aoe_duration = ability:GetSpecialValueFor("aoe_duration")
    aoe_duration = getFinalValueOperation(caster:GetPlayerID(),aoe_duration,'control',keys.AbilityLevel,nil)
    aoe_duration = getApplyControlValue(shoot, aoe_duration)
    shoot.aoe_duration = aoe_duration
    
    local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot)
    ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
    shoot.particleID = particleID
    EmitSoundOn(keys.soundCast, shoot)
    moveShoot(keys, shoot, thunderAreaBoomCallBack, nil)
end

function thunderAreaBoomCallBack(shoot)
    local keys = shoot.keysTable
    thunderAreaDuration(shoot) --实现持续光环效果以及粒子效果
    EmitSoundOn(keys.soundBoom, shoot)
end

function thunderAreaDuration(shoot)
    local keys = shoot.keysTable
    local caster = keys.caster
    local interval = 2
    thunderAreaRenderParticles(shoot)
    durationAOEDamage(shoot, interval, thunderAreaDamageCallback)
    modifierHole(shoot)
    Timers:CreateTimer(function() 
        if shoot.isKillAOE == 1 then
            return nil
        end
        local particleStun = ParticleManager:CreateParticle(keys.particles_stun, PATTACH_WORLDORIGIN, caster)
        local groundPos = GetGroundPosition(shoot:GetAbsOrigin(), shoot)
        ParticleManager:SetParticleControl(particleStun, 3, groundPos)
        ParticleManager:SetParticleControl(particleStun, 10, Vector(shoot.aoe_radius, 0, 0))
        ParticleManager:SetParticleControl(particleStun, 11, Vector(2, 0, 0))
        EmitSoundOn(keys.soundStun, shoot)
        return interval
    end)
end

function thunderAreaRenderParticles(shoot)
    local keys = shoot.keysTable
    local caster = keys.caster
	local particleBoom = ParticleManager:CreateParticle(keys.particles_duration, PATTACH_WORLDORIGIN, caster)
    local groundPos = GetGroundPosition(shoot:GetAbsOrigin(), shoot)
	ParticleManager:SetParticleControl(particleBoom, 3, groundPos)
    ParticleManager:SetParticleControl(particleBoom, 10, Vector(shoot.aoe_radius, 0, 0))
    ParticleManager:SetParticleControl(particleBoom, 11, Vector(shoot.aoe_duration+0.5, 0, 0))
end

function thunderAreaDamageCallback(shoot, unit, interval)
    local keys = shoot.keysTable
    local caster = keys.caster
    local ability = keys.ability
    local duration = ability:GetSpecialValueFor("aoe_duration")
    local damageTotal = getApplyDamageValue(shoot)
    local damage = damageTotal / (duration / interval)
    ApplyDamage({victim = unit, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType()})
    ability:ApplyDataDrivenModifier(caster, unit, keys.aoeTargetStun, {Duration = 1})

    
end

