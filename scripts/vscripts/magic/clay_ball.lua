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
    local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot)
    ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
	shoot.particleID = particleID
	EmitSoundOn(keys.soundCast, caster)
    shoot.intervalCallBack = clayBallIntervalCallBack
    moveShoot(keys, shoot, clayBallBoomCallBack, nil)
end

--技能爆炸,单次伤害
function clayBallBoomCallBack(shoot)
    --ParticleManager:DestroyParticle(shoot.particleID, true) --子弹特效消失
    clayBallRenderParticles(shoot) --爆炸粒子效果生成		  
	boomAOEOperation(shoot, clayBallAOEOperationCallback)
end

function clayBallRenderParticles(shoot)
	local keys = shoot.keysTable
	local caster = keys.caster
	--local ability = keys.ability
	local radius = shoot.aoe_radius--ability:GetSpecialValueFor("aoe_radius") 
	local particleBoom = ParticleManager:CreateParticle(keys.particles_boom, PATTACH_WORLDORIGIN, caster)
	local groundPos = GetGroundPosition(shoot:GetAbsOrigin(), shoot)
	ParticleManager:SetParticleControl(particleBoom, 3, groundPos)
	ParticleManager:SetParticleControl(particleBoom, 10, Vector(radius, 0, 0))
end

function clayBallAOEOperationCallback(shoot,unit)
	local keys = shoot.keysTable
	local caster = keys.caster
	local ability = keys.ability
    local playerID = caster:GetPlayerID()
    local AbilityLevel = shoot.abilityLevel
    local hitTargetDebuff = keys.hitTargetDebuff

	local damage = getApplyDamageValue(shoot)
	ApplyDamage({victim = unit, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType()})

    local debuffDuration = ability:GetSpecialValueFor("debuff_duration") --debuff持续时间
    debuffDuration = getFinalValueOperation(playerID,debuffDuration,'control',AbilityLevel,nil)
    debuffDuration = getApplyControlValue(shoot, debuffDuration)
    ability:ApplyDataDrivenModifier(caster, unit, hitTargetDebuff, {Duration = debuffDuration})
end

function clayBallIntervalCallBack(shoot)
    --local speed = shoot.speed
    local traveledDistance = shoot.traveled_distance
    local maxDistance = ability:GetSpecialValueFor("max_distance")
    local speedBase = ability:GetSpecialValueFor("speed") * 0.02 * GameRules.speedConstant
    local speedMax = speedBase * 2
    local speedStep = (speedMax - speedBase) * (traveledDistance / maxDistance)
    shoot.speed = shoot.speed + speedStep

end
