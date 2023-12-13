require('shoot_init')
require('skill_operation')
require('player_power')

wind_net_pre_datadriven = class({})
wind_net_datadriven = class({})
LinkLuaModifier( "wind_net_datadriven_modifier_debuff", "magic/modifiers/wind_net_modifier_debuff.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL )
LinkLuaModifier( "wind_net_pre_datadriven_modifier_debuff", "magic/modifiers/wind_net_modifier_debuff.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL )


function wind_net_pre_datadriven:GetCastRange(v,t)
    local range = getRangeByName(self,'c')
    return range
end

function wind_net_datadriven:GetCastRange(v,t)
    local range = getRangeByName(self,'c')
    return range
end

function wind_net_pre_datadriven:GetAOERadius()
	local aoe_radius = getAOERadiusByName(self,'wind_net_pre_datadriven')
	return aoe_radius
end
function wind_net_datadriven:GetAOERadius()
	local aoe_radius = getAOERadiusByName(self,'wind_net_datadriven')
	return aoe_radius
end

function wind_net_pre_datadriven:OnSpellStart()
    createShoot(self,'wind_net_pre_datadriven')
end

function wind_net_datadriven:OnSpellStart()
    createShoot(self,'wind_net_datadriven')
end

function createShoot(ability,magicName)

    local caster = ability:GetCaster()
    local keys = getMagicKeys(ability,magicName)

    keys.particles_nm = "particles/35fengzhiwang_shengcheng.vpcf"
    keys.soundCast = "magic_wind_net_cast"
	keys.particles_power = "particles/35fengzhiwang_jiaqiang.vpcf"
	keys.soundPower = "magic_wind_power_up"
	keys.particles_weak = "particles/35fengzhiwang_xueruo.vpcf"
	keys.soundWeak = "magic_wind_power_down"	

    keys.particles_misfire = "particles/35fengzhiwang_jiluo.vpcf"
    keys.soundMisfire =		"magic_wind_mis_fire"
    keys.particles_miss =    "particles/35fengzhiwang_xiaoshi.vpcf"
    keys.soundMiss =			"magic_wind_miss"

    keys.particles_boom = "particles/35fengzhiwang_mingzhong.vpcf"
    keys.soundBoom = "magic_wind_net_boom"

	keys.hitTargetDebuff = magicName.."_modifier_debuff"




    local skillPoint = ability:GetCursorPosition()
    local max_distance = ability:GetSpecialValueFor("max_distance")
	local catch_radius = ability:GetSpecialValueFor("catch_radius")
    local casterPoint = caster:GetAbsOrigin()
    local direction = (skillPoint - casterPoint):Normalized()

    local shoot = CreateUnitByName(keys.unitModel, casterPoint, true, nil, nil, caster:GetTeam())
    creatSkillShootInit(keys,shoot,caster,max_distance,direction)
    shoot.catch_radius = catch_radius
    local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot)
    ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
    shoot.particleID = particleID
    EmitSoundOn(keys.soundCast, shoot)
    moveShoot(keys, shoot, windNetBoomCallBack, nil)

end

--技能爆炸,单次伤害
function windNetBoomCallBack(shoot)
    boomAOEOperation(shoot, windNetAOEOperationCallback)
end

function windNetAOEOperationCallback(shoot,unit)
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
    unit:AddNewModifier(caster,ability,hitTargetDebuff, {Duration = debuffDuration} )
    windNetAOERenderParticles(shoot, unit, debuffDuration)
    catchAOEOperationCallback(shoot, unit, debuffDuration,hitTargetDebuff)
end

function windNetAOERenderParticles(shoot, unit, debuffDuration)
    local catch_radius = shoot.catch_radius
	local particlesName = shoot.particles_boom
	local newParticlesID = ParticleManager:CreateParticle(particlesName, PATTACH_ABSORIGIN_FOLLOW , unit)
	ParticleManager:SetParticleControlEnt(newParticlesID, 0 , unit, PATTACH_POINT_FOLLOW, nil, unit:GetAbsOrigin(), true)
	ParticleManager:SetParticleControl(newParticlesID, 14, Vector(catch_radius, 0, 0))
    ParticleManager:SetParticleControl(newParticlesID, 15, Vector(debuffDuration, 0, 0))
	if unit.tieParticleId == nil then
		unit.tieParticleId = {}
	end
	table.insert(unit.tieParticleId, newParticlesID)

end