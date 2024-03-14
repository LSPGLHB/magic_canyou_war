require('shoot_init')
require('skill_operation')
clay_ball_datadriven = class({})

LinkLuaModifier( "clay_ball_datadriven_modifier_debuff", "magic/modifiers/clay_ball_modifier_debuff.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL )

function clay_ball_datadriven:GetCastRange(v,t)
    local range = getRangeByName(self,'c')
    return range
end


function clay_ball_datadriven:GetAOERadius()
	local aoe_radius = getAOERadiusByName(self,'c')
	return aoe_radius
end


function clay_ball_datadriven:OnSpellStart()
    createShoot(self)
end

function createShoot(ability)
    local caster = ability:GetCaster()
    local magicName = ability:GetAbilityName()
    local keys = getMagicKeys(ability,magicName)

    keys.particles_nm = "particles/32niantudan_shengcheng.vpcf"
    keys.soundCast = "magic_clay_ball_cast"
	keys.particles_power = "particles/32niantudan_jiaqiang.vpcf"
	keys.soundPower = "magic_soil_power_up"
	keys.particles_weak = "particles/32niantudan_xueruo.vpcf"
	keys.soundWeak = "magic_soil_power_down"

    keys.particles_boom = "particles/32niantudan_baozha.vpcf"
    keys.soundBoom = "magic_clay_ball_boom"

	keys.hitTargetDebuff = magicName.."_modifier_debuff"

    local skillPoint = ability:GetCursorPosition()
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
	shoot.particleID = particleID
	EmitSoundOn(keys.soundCast, caster)
    shoot.intervalCallBack = clayBallIntervalCallBack
    moveShoot(keys, shoot, clayBallBoomCallBack, nil)
    caster.shootOver = 1
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
	ApplyDamage({victim = unit, attacker = shoot, damage = damage, damage_type = ability:GetAbilityDamageType()})

    local debuffDuration = ability:GetSpecialValueFor("debuff_duration") --debuff持续时间
    debuffDuration = getFinalValueOperation(playerID,debuffDuration,'control',AbilityLevel,nil)
    debuffDuration = getApplyControlValue(shoot, debuffDuration)
    --ability:ApplyDataDrivenModifier(caster, unit, hitTargetDebuff, {Duration = debuffDuration})
    unit:AddNewModifier(caster, ability, hitTargetDebuff, {Duration = debuffDuration})
end

function clayBallIntervalCallBack(shoot)
    local keys = shoot.keysTable
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    local AbilityLevel = shoot.abilityLevel
    local traveledDistance = shoot.traveled_distance
    local maxDistance = ability:GetSpecialValueFor("max_distance")
    local speedMax = getFinalValueOperation(playerID,ability:GetSpecialValueFor("speed") ,'ability_speed',AbilityLevel,nil) * GameRules.speedConstant * 0.02

    local speedBase = speedMax / 5
    local speedStep = (speedMax - speedBase) * (traveledDistance / maxDistance * 2) * (traveledDistance / maxDistance * 2)

    shoot.speed = speedBase + speedStep
    if shoot.speed > speedMax then
        shoot.speed = speedMax
    end
end
