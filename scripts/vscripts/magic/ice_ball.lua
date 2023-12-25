require('shoot_init')
require('skill_operation')
require('player_power')

ice_ball_datadriven = ({})

LinkLuaModifier( "ice_ball_datadriven_modifier_debuff", "magic/modifiers/ice_ball_modifier_debuff.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL )

function ice_ball_datadriven:GetCastRange(v,t)
    local range = getRangeByName(self,'a')
    return range
end

function ice_ball_datadriven:GetAOERadius()
	local aoe_radius = getAOERadiusByName(self,'a')
	return aoe_radius
end

function ice_ball_datadriven:OnSpellStart()
    createShoot(self)
end

function createShoot(ability)
    local caster = ability:GetCaster()
    local magicName = ability:GetAbilityName()
    local keys = getMagicKeys(ability,magicName)

    keys.particles_nm =      "particles/04bingqiu_shengcheng.vpcf"
    keys.soundCast = 		"magic_ice_ball_cast"
    keys.particles_misfire = "particles/04bingqiu_jiluo.vpcf"
    keys.soundMisfire =		"magic_ice_mis_fire"
    keys.particles_miss =    "particles/04bingqiu_xiaoshi.vpcf"
    keys.soundMiss =			"magic_ice_miss"
    keys.particles_power = 	"particles/04bingqiu_jiaqiang.vpcf"
    keys.soundPower =		"magic_ice_power_up"
    keys.particles_weak = 	"particles/04bingqiu_xueruo.vpcf"
    keys.soundWeak =			"magic_ice_power_down"	   
    keys.particles_boom = 	"particles/04bingqiu_mingzhong.vpcf"
    keys.soundBoom =			"magic_ice_ball_boom"
    keys.hitTargetDebuff =   "ice_ball_datadriven_modifier_debuff"

    local skillPoint = ability:GetCursorPosition()
    --local speed = ability:GetSpecialValueFor("speed")
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
    moveShoot(keys, shoot, iceBallBoomCallBack, nil)

end

--技能爆炸,单次伤害
--技能爆炸,单次伤害
function iceBallBoomCallBack(shoot)
	boomAOERenderParticles(shoot)
    boomAOEOperation(shoot, iceBallAOEOperationCallback)
end
function boomAOERenderParticles(shoot)
	local particlesName = shoot.particles_boom
	local newParticlesID = ParticleManager:CreateParticle(particlesName, PATTACH_ABSORIGIN_FOLLOW , shoot)
	ParticleManager:SetParticleControlEnt(newParticlesID, shoot.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
end

function iceBallAOEOperationCallback(shoot,unit)
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
    --ability:ApplyDataDrivenModifier(caster, unit, hitTargetDebuff, {Duration = debuffDuration}) 
    unit:AddNewModifier(caster,ability,hitTargetDebuff, {Duration = debuffDuration})
end