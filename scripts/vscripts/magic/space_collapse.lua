require('shoot_init')
require('skill_operation')
space_collapse_datadriven =({})
LinkLuaModifier("modifier_space_collapse_aoe_debuff", "magic/modifiers/space_collapse_modifier_debuff.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)

function space_collapse_datadriven:GetCastRange(v,t)
    local range = getRangeByName(self,'a')
    return range
end

function space_collapse_datadriven:GetAOERadius(v,t)
	local aoe_radius = getAOERadiusByName(self,'a')
	return aoe_radius
end

function space_collapse_datadriven:OnSpellStart()
    createShoot(self)
end

function createShoot(ability)
    local caster = ability:GetCaster()
    local magicName = ability:GetAbilityName()
    local keys = getMagicKeys(ability,magicName)

	keys.shootHight =		5
	keys.particles_nm =      "particles/15kongjiantansuo_shengcheng.vpcf"
	keys.soundCast = 		"magic_space_collapse_cast"
	keys.particles_power = 	"particles/15kongjiantansuo_jiaqiang.vpcf"
	keys.soundWeak =			"magic_wind_power_up"
	keys.particles_weak = 	"particles/15kongjiantansuo_xueruo.vpcf"	
	keys.soundWeak =			"magic_wind_power_down"
	keys.particles_boom = 	"particles/15kongjiantansuo_baozha.vpcf"
	keys.soundBoom =		    "magic_space_collapse_boom"
	keys.aoeTargetDebuff =	"modifier_space_collapse_aoe_debuff"


	local playerID = caster:GetPlayerID()
	local speed = ability:GetSpecialValueFor("speed")
	local skillPoint = ability:GetCursorPosition()
	local casterPoint = caster:GetAbsOrigin()
	local max_distance =  (skillPoint - casterPoint ):Length2D()--ability:GetSpecialValueFor("max_distance")
	
	
	local G_Speed = ability:GetSpecialValueFor("G_speed") * GameRules.speedConstant * 0.02
	local position = caster:GetAbsOrigin()
	local direction = (skillPoint - position):Normalized()
	local shoot = CreateUnitByName(keys.unitModel, position, true, nil, nil, caster:GetTeam())
	creatSkillShootInit(keys,shoot,caster,max_distance,direction)
	initDurationBuff(keys)

	--过滤掉增加施法距离的操作
	shoot.max_distance_operation = max_distance
	shoot.G_Speed = G_Speed

	local aoe_duration = ability:GetSpecialValueFor("aoe_duration") --AOE持续作用时间
	aoe_duration = getFinalValueOperation(playerID,aoe_duration,'control',shoot.abilityLevel,nil)--数值加强
	aoe_duration = getApplyControlValue(shoot, aoe_duration)--克制加强
	shoot.aoe_duration = aoe_duration


	local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot) 
	ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
	shoot.particleID = particleID
	EmitSoundOn(keys.soundCast, shoot)
	moveShoot(keys, shoot, spaceCollapseBoomCallBack, nil)
	caster.shootOver = 1
end

function spaceCollapseBoomCallBack(shoot)
    spaceCollapseRenderParticles(shoot)
    spaceCollapseDuration(shoot) 
end

function spaceCollapseDuration(shoot)
	local interval = 0.1
    shootSoundAndParticle(shoot, "boom")
    durationAOEDamage(shoot, interval, damageCallback)
	modifierHole(shoot)
	blackHole(shoot)
end

--特效显示效果
function spaceCollapseRenderParticles(shoot)
	local keys = shoot.keysTable
    local caster = keys.caster
	--local ability = keys.ability
	local aoe_radius = shoot.aoe_radius

	local particleBoom = ParticleManager:CreateParticle(keys.particles_boom, PATTACH_WORLDORIGIN, caster)
    local shootPos = shoot:GetAbsOrigin()
	ParticleManager:SetParticleControl(particleBoom, 3, Vector(shootPos.x,shootPos.y,shootPos.z))
	ParticleManager:SetParticleControl(particleBoom, 10, Vector(aoe_radius, 0, 0))
end

