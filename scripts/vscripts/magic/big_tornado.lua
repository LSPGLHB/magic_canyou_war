require('shoot_init')
require('skill_operation')
big_tornado_pre_datadriven = class({})
big_tornado_datadriven = class({})
LinkLuaModifier( "big_tornado_datadriven_modifier_debuff", "magic/modifiers/big_tornado_modifier_debuff.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL )
LinkLuaModifier( "big_tornado_pre_datadriven_modifier_debuff", "magic/modifiers/big_tornado_modifier_debuff.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL )


function big_tornado_pre_datadriven:GetCastRange(v,t)
    local range = getRangeByName(self,'c')
    return range
end

function big_tornado_datadriven:GetCastRange(v,t)
    local range = getRangeByName(self,'c')
    return range
end

function big_tornado_pre_datadriven:GetAOERadius()
	local aoe_radius = getAOERadiusByName(self,'c')
	return aoe_radius
end
function big_tornado_datadriven:GetAOERadius()
	local aoe_radius = getAOERadiusByName(self,'c')
	return aoe_radius
end

function big_tornado_pre_datadriven:OnSpellStart()
    createShoot(self)
end

function big_tornado_datadriven:OnSpellStart()
    createShoot(self)
end



function createShoot(ability,magicName)
    local caster = ability:GetCaster()
	local magicName = ability:GetAbilityName()
    local keys = getMagicKeys(ability,magicName)

    keys.particles_nm = "particles/30dalongjuanfeng_shengcheng.vpcf"
    keys.soundCast = "magic_big_tornado_cast"
	keys.particles_power = "particles/30dalongjuanfeng_jiaqiang.vpcf"
	keys.soundPower = "magic_wind_power_up"
	keys.particles_weak ="particles/30dalongjuanfeng_xueruo.vpcf"
	keys.soundWeak = "magic_wind_power_down"	


    keys.particles_duration = "particles/30dalongjuanfeng_baozha.vpcf"
    keys.soundBoom = "magic_wind_boom"

	keys.soundDurationDelay = 0.25
	keys.soundDuration = "magic_big_tornado_duration"	

	keys.aoeTargetDebuff =	magicName.."_modifier_debuff"
	keys.shootHight = 5

				

	local playerID = caster:GetPlayerID()
	--local speed = ability:GetSpecialValueFor("speed")
	local skillPoint = ability:GetCursorPosition()
	local casterPoint = caster:GetAbsOrigin()
	local max_distance = (skillPoint - casterPoint ):Length2D()--ability:GetSpecialValueFor("max_distance")
	--local aoe_radius = ability:GetSpecialValueFor("aoe_radius")--半径
	
	local position = caster:GetAbsOrigin()
	local direction = (skillPoint - position):Normalized()
	local shoot = CreateUnitByName(keys.unitModel, position, true, nil, nil, caster:GetTeam())
	creatSkillShootInit(keys,shoot,caster,max_distance,direction)
	initDurationBuff(keys)
	--过滤掉增加施法距离的操作
	shoot.max_distance_operation = max_distance
	--效果可加强项目
	local aoe_duration = ability:GetSpecialValueFor("aoe_duration") --AOE持续作用时间
	aoe_duration = getFinalValueOperation(playerID,aoe_duration,'control',shoot.abilityLevel,nil)--数值加强
	aoe_duration = getApplyControlValue(shoot, aoe_duration)--克制加强
	shoot.aoe_duration = aoe_duration
	local G_Speed = ability:GetSpecialValueFor("G_speed") * GameRules.speedConstant * 0.02
	G_Speed = getFinalValueOperation(playerID,G_Speed,'control',shoot.abilityLevel,nil)--数值计算
	G_Speed = getApplyControlValue(shoot, G_Speed)--克制加强
	shoot.G_Speed = G_Speed
	
	
	local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot) 
	ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
	shoot.particleID = particleID
	EmitSoundOn(keys.soundCast, shoot)
	moveShoot(keys, shoot, bigTornadoBoomCallBack, nil)
end

function bigTornadoBoomCallBack(shoot)
    bigTornadoDuration(shoot) --实现持续光环效果以及粒子效果
end

function bigTornadoDuration(shoot)
	local interval = 0.5
    bigTornadoRenderParticles(shoot)
    durationAOEDamage(shoot, interval, damageCallback)
	modifierHole(shoot)
	blackHole(shoot)
end

--特效显示效果
function bigTornadoRenderParticles(shoot)
	local keys = shoot.keysTable
    local caster = keys.caster
	--local ability = keys.ability
	EmitSoundOn(keys.soundBoom, shoot)
	local aoe_radius = shoot.aoe_radius
    local aoe_duration = shoot.aoe_duration
	local shootPos = shoot:GetAbsOrigin()
	local particleBoom = ParticleManager:CreateParticle(keys.particles_duration, PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(particleBoom, 3, Vector(shootPos.x,shootPos.y,shootPos.z))
	ParticleManager:SetParticleControl(particleBoom, 1, Vector(aoe_radius, 0, 0))
	ParticleManager:SetParticleControl(particleBoom, 11, Vector(aoe_duration, 0, 0))
end



