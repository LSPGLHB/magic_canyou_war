require('shoot_init')
require('skill_operation')
function createFireBottle(keys)
    local caster = keys.caster
    local ability = keys.ability
    local skillPoint = ability:GetCursorPosition()
    local speed = ability:GetSpecialValueFor("speed")
    local casterPoint = caster:GetAbsOrigin()
    local max_distance = (skillPoint - casterPoint ):Length2D()
    local direction = (skillPoint - casterPoint):Normalized()
    local shoot = CreateUnitByName(keys.unitModel, casterPoint, true, nil, nil, caster:GetTeam())
    creatSkillShootInit(keys,shoot,caster,max_distance,direction)
    --过滤掉增加施法距离的操作
	shoot.max_distance_operation = max_distance
    initDurationBuff(keys)
    local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot)
    ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
    moveShoot(keys, shoot, particleID, fireBottleBoomCallBack, nil)
end


function fireBottleBoomCallBack(keys,shoot,particleID)
    ParticleManager:DestroyParticle(particleID, true) --子弹特效消失 
    fireBottleDuration(keys,shoot) --实现持续光环效果以及粒子效果
    EmitSoundOn("magic_fire_bottle_boom", shoot)
end



function fireBottleDuration(keys,shoot)
   
    local interval = 0.5
    local particleBoom = fireBottleRenderParticles(keys,shoot)

    Timers:CreateTimer(0.8,function ()
        EmitSoundOn("magic_fire_bottle_duration", shoot)
        return nil
    end)

    durationAOEDamage(keys, shoot, interval, particleBoom, radiusDamagePower)
end


function fireBottleRenderParticles(keys,shoot)
    local caster = keys.caster
	local ability = keys.ability
	local radius = ability:GetSpecialValueFor("aoe_radius")
    local duration = ability:GetSpecialValueFor("aoe_duration")    
	local particleBoom = ParticleManager:CreateParticle(keys.particlesBoom, PATTACH_WORLDORIGIN, caster)
    local groundPos = GetGroundPosition(shoot:GetAbsOrigin(), shoot)
	ParticleManager:SetParticleControl(particleBoom, 3, groundPos)
    ParticleManager:SetParticleControl(particleBoom, 11, Vector(duration, 0, 0))
	ParticleManager:SetParticleControl(particleBoom, 10, Vector(radius, 1, 0))
    return particleBoom
end


function radiusDamagePower(shootPos, unitPos, radius, damage)
    local distance = (shootPos - unitPos):Length2D()
    if distance < 0.5 * radius then
        damage = damage * 2
    end
    return damage
end