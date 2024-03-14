require('shoot_init')
require('skill_operation')
require('player_power')
twine_soil_ball_pre_datadriven = class({})
twine_soil_ball_datadriven = class({})
LinkLuaModifier( "twine_soil_ball_datadriven_modifier_debuff", "magic/modifiers/twine_soil_ball_modifier_debuff.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL )
LinkLuaModifier( "twine_soil_ball_pre_datadriven_modifier_debuff", "magic/modifiers/twine_soil_ball_modifier_debuff.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL )


function twine_soil_ball_pre_datadriven:GetCastRange(v,t)
    local range = getRangeByName(self,'c')
    return range
end

function twine_soil_ball_datadriven:GetCastRange(v,t)
    local range = getRangeByName(self,'c')
    return range
end

function twine_soil_ball_pre_datadriven:GetAOERadius()
	local aoe_radius = getAOERadiusByName(self,'c')
	return aoe_radius
end
function twine_soil_ball_datadriven:GetAOERadius()
	local aoe_radius = getAOERadiusByName(self,'c')
	return aoe_radius
end

function twine_soil_ball_pre_datadriven:OnSpellStart()
    createTwineSoilBall(self)
end

function twine_soil_ball_datadriven:OnSpellStart()
    createTwineSoilBall(self)
end

function createTwineSoilBall(ability)
    local caster = ability:GetCaster()
    local magicName = ability:GetAbilityName()
    local keys = getMagicKeys(ability,magicName)

    keys.particles_nm = "particles/02tuqiushu_shengcheng.vpcf"
    keys.soundCast = "magic_twine_soil_ball_cast"
	keys.particles_power = "particles/02tuqiushu_jiaqiang.vpcf"
	keys.soundPower = "magic_soil_power_up"
	keys.particles_weak = "particles/02tuqiushu_xueruo.vpcf"
	keys.soundWeak = "magic_soil_power_down"	

    keys.particles_misfire = "particles/02tuqiushu_jiluo.vpcf"
    keys.soundMisfire =		"magic_soil_mis_fire"
    keys.particles_miss =    "particles/02tuqiushu_xiaoshi.vpcf"
    keys.soundMiss =			"magic_soil_miss"

    keys.particles_boom = "particles/02tuqiushu_mingzhong.vpcf"
    keys.soundBoom = "magic_twine_soil_ball_hit"

	keys.hitTargetDebuff = magicName.."_modifier_debuff"



    local skillPoint = ability:GetCursorPosition()
    local speed = ability:GetSpecialValueFor("speed")
    local max_distance = ability:GetSpecialValueFor("max_distance")

    local casterPoint = caster:GetAbsOrigin()
    local direction = (skillPoint - casterPoint):Normalized()

    local shoot = CreateUnitByName(keys.unitModel, casterPoint, true, nil, nil, caster:GetTeam())
    creatSkillShootInit(keys,shoot,caster,max_distance,direction)
    --shoot.aoe_radius = aoe_radius
    local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot)
    ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
    shoot.particleID = particleID
    EmitSoundOn(keys.soundCast, shoot)
    moveShoot(keys, shoot, twineSoilBallBoomCallBack, nil)
    caster.shootOver = 1
end

--技能爆炸,单次伤害
function twineSoilBallBoomCallBack(shoot)
	twineSoilBalllRenderParticles(shoot)
    boomAOEOperation(shoot, twineSoilBallBoomOperationCallback)
end

function twineSoilBalllRenderParticles(shoot)
	local particlesName = shoot.particles_boom
	local newParticlesID = ParticleManager:CreateParticle(particlesName, PATTACH_ABSORIGIN_FOLLOW , shoot)
	ParticleManager:SetParticleControlEnt(newParticlesID, shoot.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
end

function twineSoilBallBoomOperationCallback(shoot,unit)
	local keys = shoot.keysTable
    local caster = keys.caster
	local playerID = caster:GetPlayerID()
	local ability = keys.ability
    local AbilityLevel = shoot.abilityLevel
    local hitTargetDebuff = keys.hitTargetDebuff
    local damage = getApplyDamageValue(shoot)
    ApplyDamage({victim = unit, attacker = shoot, damage = damage, damage_type = ability:GetAbilityDamageType()})

    local debuffDuration = ability:GetSpecialValueFor("debuff_duration") --debuff持续时间
    debuffDuration = getFinalValueOperation(playerID,debuffDuration,'control',AbilityLevel,nil)
    debuffDuration = getApplyControlValue(shoot, debuffDuration)
    --ability:ApplyDataDrivenModifier(caster, unit, debuffName, {Duration = debuffDuration})
    unit:AddNewModifier(caster,ability,hitTargetDebuff, {Duration = debuffDuration} )
end 

