require('shoot_init')
require('skill_operation')
require('player_power')
function createShoot(keys)
    local caster = keys.caster
    local ability = keys.ability
    local skillPoint = ability:GetCursorPosition()
	local casterPoint = caster:GetAbsOrigin()
	
    --local speed = ability:GetSpecialValueFor("speed")
	--local aoe_radius = ability:GetSpecialValueFor("aoe_radius") 
    
    local max_distance = (skillPoint - casterPoint ):Length2D()
    local direction = (skillPoint - casterPoint):Normalized()
    local shoot = CreateUnitByName(keys.unitModel, casterPoint, true, nil, nil, caster:GetTeam())
    creatSkillShootInit(keys,shoot,caster,max_distance,direction)
    --过滤掉增加施法距离的操作
	shoot.max_distance_operation = max_distance
    initDurationBuff(keys)

	--local AbilityLevel = shoot.abilityLevel
	--local playerID = caster:GetPlayerID()
	--aoe_radius = getFinalValueOperation(playerID,aoe_radius,'radius',AbilityLevel,nil)--数值加强
	--shoot.aoe_radius = aoe_radius

    local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot)
    ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
	shoot.particleID = particleID
	EmitSoundOn(keys.soundCast, caster)
    moveShoot(keys, shoot, fireBallBoomCallBack, nil)
end

--技能爆炸,单次伤害
function fireBallBoomCallBack(shoot)
    --ParticleManager:DestroyParticle(shoot.particleID, true) --子弹特效消失
    fireBallRenderParticles(shoot) --爆炸粒子效果生成		  
	boomAOEOperation(shoot, fireBallAOEOperationCallback)
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

function fireBallAOEOperationCallback(shoot,unit)
	local keys = shoot.keysTable
	local caster = keys.caster
	local ability = keys.ability
	local playerID = caster:GetPlayerID()
	local AbilityLevel = shoot.abilityLevel
	local beatBackDistance = ability:GetSpecialValueFor("beat_back_distance")
	local beatBackSpeed = ability:GetSpecialValueFor("beat_back_speed") 
	beatBackDistance = getFinalValueOperation(playerID,beatBackDistance,'control',AbilityLevel,nil)--装备数值加强
	beatBackDistance = getApplyControlValue(shoot,beatBackDistance)--相生相克计算
	local shootPos = shoot:GetAbsOrigin()
	local tempShootPos  = Vector(shootPos.x,shootPos.y,0)
	local targetPos= unit:GetAbsOrigin()
	local tempTargetPos = Vector(targetPos.x ,targetPos.y ,0)
	local beatBackDirection =  (tempTargetPos - tempShootPos):Normalized()
	beatBackUnit(keys,shoot,unit,beatBackSpeed,beatBackDistance,beatBackDirection,true)
	local damage = getApplyDamageValue(shoot)
	ApplyDamage({victim = unit, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType()})
end

