require('shoot_init')
require('skill_operation')
function createVisionDownLightBall(keys)
    local caster = keys.caster
    local ability = keys.ability
    local skillPoint = ability:GetCursorPosition()
    local speed = ability:GetSpecialValueFor("speed")
    --local max_distance = ability:GetSpecialValueFor("max_distance")
    local angleRate = ability:GetSpecialValueFor("angle_rate") * math.pi
    local casterPoint = caster:GetAbsOrigin()
    local direction = (skillPoint - casterPoint):Normalized()
    local max_distance = (skillPoint - casterPoint ):Length2D()
    local shoot = CreateUnitByName(keys.unitModel, casterPoint, true, nil, nil, caster:GetTeam())
    creatSkillShootInit(keys,shoot,caster,max_distance,direction)
    shoot.max_distance_operation = max_distance
    initDurationBuff(keys)
    local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot)
    ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
    moveShoot(keys, shoot, particleID, visionDownLightBallBoomCallBack, nil)

end

function visionDownLightBallBoomCallBack(keys,shoot,particleID)
    ParticleManager:DestroyParticle(particleID, true) --子弹特效消失 
    visionDownLightBallDuration(keys,shoot) --实现持续光环效果以及粒子效果
    EmitSoundOn("magic_vision_down_light_ball_duration", shoot)
end



function visionDownLightBallDuration(keys,shoot)
    local interval = 0.5
    local particleBoom = visionDownLightBallRenderParticles(keys,shoot)
    durationAOEDamage(keys, shoot, interval, particleBoom, nil)
end


function visionDownLightBallRenderParticles(keys,shoot)
    local caster = keys.caster
	local ability = keys.ability
	local radius = ability:GetSpecialValueFor("aoe_radius")
    local duration = ability:GetSpecialValueFor("aoe_duration")    
	local particleBoom = ParticleManager:CreateParticle(keys.particlesBoom, PATTACH_WORLDORIGIN, caster)
    local groundPos = shoot:GetAbsOrigin()--GetGroundPosition(shoot:GetAbsOrigin(), shoot)
	ParticleManager:SetParticleControl(particleBoom, 3, groundPos)
    ParticleManager:SetParticleControl(particleBoom, 11, Vector(duration, 0, 0))
	ParticleManager:SetParticleControl(particleBoom, 10, Vector(radius, 1, 0))
    return particleBoom
end

