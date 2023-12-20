require('shoot_init')
require('skill_operation')

small_hurricane_datadriven =({})
LinkLuaModifier("modifier_small_hurricane_shoot_debuff", "magic/modifiers/small_hurricane_modifier_debuff.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_small_hurricane_aoe_debuff", "magic/modifiers/small_hurricane_modifier_debuff.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)


function small_hurricane_datadriven:GetCastRange(v,t)
    local range = getRangeByName(self,'b')
    return range
end

function small_hurricane_datadriven:GetAOERadius(v,t)
	local aoe_radius = getAOERadiusByName(self,'b')
	return aoe_radius
end

function small_hurricane_datadriven:OnSpellStart()
    createShoot(self)
end


function createShoot(ability)
    local caster = ability:GetCaster()
    local magicName = ability:GetAbilityName()
    local keys = getMagicKeys(ability,magicName)

	keys.isMultipleHit =		1  --子弹可多次击中同一单位
	keys.particles_nm =      "particles/40xiaojufeng_shengcheng.vpcf"
	keys.soundCast = 		"magic_small_hurricane_cast"
	keys.particles_power = 	"particles/40xiaojufeng_jiaqiang.vpcf"
	keys.soundPower =			"magic_wind_power_up"
	keys.particles_weak = 	"particles/40xiaojufeng_xueruo.vpcf"	
	keys.soundWeak =			"magic_wind_power_down"
	keys.particles_duration = 	"particles/40xiaojufeng_baozha.vpcf"
	keys.soundBoom =			"magic_wind_boom"
	keys.soundDurationDelay = 0.25
	keys.soundDuration =		"magic_small_hurricane_duration"
	keys.shootAoeDebuff =	"modifier_small_hurricane_shoot_debuff"	
	keys.aoeTargetDebuff =	"modifier_small_hurricane_aoe_debuff"

	local playerID = caster:GetPlayerID()

	local max_distance = ability:GetSpecialValueFor("max_distance")
	
	local position = caster:GetAbsOrigin()
	local direction = (ability:GetCursorPosition() - position):Normalized()
	local shoot = CreateUnitByName(keys.unitModel, position, true, nil, nil, caster:GetTeam())
	creatSkillShootInit(keys,shoot,caster,max_distance,direction)
	initDurationBuff(keys)

	local aoe_duration = ability:GetSpecialValueFor("aoe_duration") --AOE持续作用时间
	aoe_duration = getFinalValueOperation(playerID,aoe_duration,'control',shoot.abilityLevel,nil)--数值加强
	aoe_duration = getApplyControlValue(shoot, aoe_duration)--克制加强
	shoot.aoe_duration = aoe_duration	
	local G_Speed = ability:GetSpecialValueFor("G_speed") * GameRules.speedConstant * 0.02
	G_Speed = getFinalValueOperation(playerID,G_Speed,'control',shoot.abilityLevel,nil)--数值计算
	G_Speed = getApplyControlValue(shoot, G_Speed)--克制计算
	shoot.G_Speed = G_Speed
	

	local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot) 
	ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
	shoot.particleID = particleID
	EmitSoundOn(keys.soundCast, shoot)
	shoot.castTime = GameRules:GetGameTime()
	moveShoot(keys, shoot, smallHurricaneBoomCallBack, smallHurricaneTakeAwayCallBack)
		
end

function smallHurricaneBoomCallBack(shoot)	
    smallHurricaneDuration(shoot) --实现持续光环效果以及粒子效果
end

function smallHurricaneDuration(shoot)
	local interval = 0.5
    smallHurricaneRenderParticles(shoot)
    durationAOEDamage(shoot, interval, damageCallback)

	modifierHole(shoot)
	blackHole(shoot)
end

--特效显示效果
function smallHurricaneRenderParticles(shoot)
	local keys = shoot.keysTable
    local caster = keys.caster
	--local ability = keys.ability
	EmitSoundOn(keys.soundBoom, shoot)
	local aoe_radius = shoot.aoe_radius
    local aoe_duration = shoot.aoe_duration
	local particleBoom = ParticleManager:CreateParticle(keys.particles_duration, PATTACH_WORLDORIGIN, caster)
    local shootPos = shoot:GetAbsOrigin()
	ParticleManager:SetParticleControl(particleBoom, 3, Vector(shootPos.x,shootPos.y,shootPos.z))
	ParticleManager:SetParticleControl(particleBoom, 10, Vector(aoe_radius, 0, 0))
	ParticleManager:SetParticleControl(particleBoom, 11, Vector(aoe_duration, 0, 0))
end

function smallHurricaneTakeAwayCallBack(shoot, unit)
	takeAwayUnit(shoot, unit)
end

