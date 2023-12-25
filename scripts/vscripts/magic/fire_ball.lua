fire_ball_datadriven = class({})
LinkLuaModifier( "modifier_beat_back", "magic/modifiers/modifier_beat_back.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL )
LinkLuaModifier( "modifier_disable_turning", "magic/modifiers/modifier_disable_turning.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL )

require('shoot_init')
require('skill_operation')
require('player_power')
function fire_ball_datadriven:GetAOERadius(v,t)
	local aoe_radius = getAOERadiusByName(self,'b')
	return aoe_radius
end

function fire_ball_datadriven:GetCastRange(v,t)
    local range = getRangeByName(self,'b')
    return range
end

function fire_ball_datadriven:OnSpellStart()
	createShoot(self)
end

function createShoot(ability)
	local caster = ability:GetCaster()
	local magicName = ability:GetAbilityName()
    local keys = getMagicKeys(ability,magicName)

	keys.particles_nm = "particles/06huoqiushu_shengcheng.vpcf"
    keys.soundCast = "magic_fire_ball_cast"
	keys.particles_power = "particles/06huoqiushu_jiaqiang.vpcf"
	keys.soundPower = "magic_fire_power_up"
	keys.particles_weak ="particles/06huoqiushu_xueruo.vpcf"
	keys.soundWeak = "magic_fire_power_down"

    keys.particles_boom =  "particles/06huoqiushu_baozha.vpcf"
    keys.soundBoom = "magic_fire_ball_boom"
	keys.soundBeat = "magic_beat_hit"

	keys.hitTargetDebuff = "modifier_beat_back"
	keys.hitDisableTurning = "modifier_disable_turning"

	local skillPoint = ability:GetCursorPosition()
	local casterPoint = caster:GetAbsOrigin()
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
	--print("fireBallBoomCallBack")
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
	--print("fireBallAOEOperationCallback")
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
	beatBackUnit(keys,shoot,unit,beatBackSpeed,beatBackDistance,beatBackDirection,AbilityLevel,true)
	disableTurning(keys,shoot,unit,AbilityLevel)
	local damage = getApplyDamageValue(shoot)
	ApplyDamage({victim = unit, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType()})
end




