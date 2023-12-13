require('shoot_init')
require('skill_operation')
water_ball_pre_datadriven = class({})
water_ball_datadriven = class({})
LinkLuaModifier( "water_ball_datadriven_modifier_debuff", "magic/modifiers/water_ball_modifier_debuff.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL )
LinkLuaModifier( "water_ball_pre_datadriven_modifier_debuff", "magic/modifiers/water_ball_modifier_debuff.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL )

function water_ball_pre_datadriven:GetCastRange(v,t)
    local range = getRangeByName(self,'c')
    return range
end

function water_ball_datadriven:GetCastRange(v,t)
    local range = getRangeByName(self,'c')
    return range
end

function water_ball_pre_datadriven:GetAOERadius()
	local aoe_radius = getAOERadiusByName(self,'water_ball_pre_datadriven')
	return aoe_radius
end
function water_ball_datadriven:GetAOERadius()
	local aoe_radius = getAOERadiusByName(self,'water_ball_datadriven')
	return aoe_radius
end

function water_ball_pre_datadriven:OnSpellStart()
    createShoot(self,'water_ball_pre_datadriven')
end

function water_ball_datadriven:OnSpellStart()
    createShoot(self,'water_ball_datadriven')
end



function createShoot(ability,magicName)
    local caster = ability:GetCaster()
    local keys = getMagicKeys(ability,magicName)

    keys.particles_nm = "particles/19shuiqiushu_shengcheng.vpcf"
    keys.soundCast = "magic_water_ball_cast"
	keys.particles_power = "particles/19shuiqiushu_jiaqiang.vpcf"
	keys.soundPower = "magic_water_power_up"
	keys.particles_weak = "particles/19shuiqiushu_xueruo.vpcf"
	keys.soundWeak = "magic_water_power_down"

    keys.particles_boom = "particles/19shuiqiushu_baozha.vpcf"
    keys.soundBoom = "magic_water_ball_boom"

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
    moveShoot(keys, shoot, waterBallBoomCallBack, nil)
end

--技能爆炸,单次伤害
function waterBallBoomCallBack(shoot)
    --ParticleManager:DestroyParticle(shoot.particleID, true) --子弹特效消失
    waterBallRenderParticles(shoot) --爆炸粒子效果生成		  
	boomAOEOperation(shoot, waterBallAOEOperationCallback)
end

function waterBallRenderParticles(shoot)
	local keys = shoot.keysTable
	local caster = keys.caster
	--local ability = keys.ability
	local radius = shoot.aoe_radius--ability:GetSpecialValueFor("aoe_radius") 
	local particleBoom = ParticleManager:CreateParticle(keys.particles_boom, PATTACH_WORLDORIGIN, caster)
	local groundPos = GetGroundPosition(shoot:GetAbsOrigin(), shoot)
	ParticleManager:SetParticleControl(particleBoom, 0, groundPos)
	ParticleManager:SetParticleControl(particleBoom, 1, Vector(radius, 0, 0))
end

function waterBallAOEOperationCallback(shoot,unit)
	local keys = shoot.keysTable
	local caster = keys.caster
	local ability = keys.ability
	local damage = getApplyDamageValue(shoot)
	ApplyDamage({victim = unit, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType()})

    local AbilityLevel = shoot.abilityLevel
    local hitTargetDebuff = keys.hitTargetDebuff
    local playerID = caster:GetPlayerID()
    local debuffDuration = ability:GetSpecialValueFor("debuff_duration") --debuff持续时间
    debuffDuration = getFinalValueOperation(playerID,debuffDuration,'control',AbilityLevel,nil)
    debuffDuration = getApplyControlValue(shoot, debuffDuration)
    --ability:ApplyDataDrivenModifier(caster, unit, hitTargetDebuff, {Duration = debuffDuration})  --特效有问题，没有无限循环
    unit:AddNewModifier(caster,ability,hitTargetDebuff, {Duration = debuffDuration} )
end

