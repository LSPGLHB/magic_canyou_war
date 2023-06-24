require('shoot_init')
require('skill_operation')
function createFireBall(keys)
    local caster = keys.caster
    local ability = keys.ability
    local skillPoint = ability:GetCursorPosition()
    --local speed = ability:GetSpecialValueFor("speed")
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
    local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot)
    ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
	shoot.particleID = particleID
	EmitSoundOn(keys.soundCast, caster)
    moveShoot(keys, shoot, FireBallBoomCallBack, nil)
end

--技能爆炸,单次伤害
function FireBallBoomCallBack(shoot)
    ParticleManager:DestroyParticle(shoot.particleID, true) --子弹特效消失
    fireBallRenderParticles(shoot) --爆炸粒子效果生成		  
	boomAOEOperation(shoot, AOEOperationCallback)
end

function fireBallRenderParticles(shoot)
	local keys = shoot.keysTable
	local caster = keys.caster
	--local ability = keys.ability
	local radius = shoot.aoe_radius--ability:GetSpecialValueFor("aoe_radius") 
	local particleBoom = ParticleManager:CreateParticle(keys.particles_boom, PATTACH_WORLDORIGIN, caster)
	local groundPos = GetGroundPosition(shoot:GetAbsOrigin(), shoot)
	ParticleManager:SetParticleControl(particleBoom, 3, groundPos)
	ParticleManager:SetParticleControl(particleBoom, 10, Vector(radius, 0, 0))
end

function AOEOperationCallback(shoot,unit)
	local keys = shoot.keysTable
	--local caster = keys.caster
	local ability = keys.ability
	local beatBackDistance = ability:GetSpecialValueFor("beat_back_distance")
	local beatBackSpeed = ability:GetSpecialValueFor("beat_back_speed") 
	beatBackUnit(keys,shoot,unit,beatBackSpeed,beatBackDistance,true)
	local damage = getApplyDamageValue(shoot)
	ApplyDamage({victim = unit, attacker = shoot, damage = damage, damage_type = ability:GetAbilityDamageType()})
end

