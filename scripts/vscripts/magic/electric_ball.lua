require('shoot_init')
require('skill_operation')
electric_ball_datadriven = class({})
LinkLuaModifier( "electric_ball_datadriven_modifier_debuff", "magic/modifiers/electric_ball_modifier.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL )
LinkLuaModifier( "modifier_electric_ball_stun", "magic/modifiers/electric_ball_modifier.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL )

function electric_ball_datadriven:GetCastRange(v,t)
    local range = getRangeByName(self,'c')
    return range
end

function electric_ball_datadriven:GetAOERadius()
	local aoe_radius = getAOERadiusByName(self,'c')
	return aoe_radius
end

function electric_ball_datadriven:OnSpellStart()
    createShoot(self)
end

function createShoot(ability)
    local caster = ability:GetCaster()
    local magicName = ability:GetAbilityName()
    local keys = getMagicKeys(ability,magicName)

    keys.particles_nm =      "particles/18sansheleiqiu_shengcheng.vpcf"
    keys.soundCast =			"magic_electric_ball_cast"
    
    keys.particles_power = 	"particles/18sansheleiqiu_jiaqiang.vpcf"
    keys.soundPower =	"magic_electric_power_up"
    keys.particles_weak = 	"particles/18sansheleiqiu_xueruo.vpcf"
    keys.soundWeak =			"magic_electric_power_down"
    keys.particles_misfire = "particles/18sansheleiqiu_jiluo.vpcf"
    keys.soundMisfire =		"magic_electric_mis_fire"
    keys.particles_miss =    "particles/18sansheleiqiu_xiaoshi.vpcf"
    keys.soundMiss =			"magic_electric_miss"
    keys.particles_boom = 	"particles/18sansheleiqiu_mingzhong.vpcf"
    keys.soundBoom =			"magic_electric_ball_boom"

    keys.hitTargetDebuff =   magicName.."_modifier_debuff"
    keys.stunDebuff =        "modifier_electric_ball_stun"




    local skillPoint = ability:GetCursorPosition()

    local casterPoint = caster:GetAbsOrigin()
    local max_distance = ability:GetSpecialValueFor("max_distance")
    local direction = (skillPoint - casterPoint):Normalized()
    local shoot = CreateUnitByName(keys.unitModel, casterPoint, true, nil, nil, caster:GetTeam())
    creatSkillShootInit(keys,shoot,caster,max_distance,direction)
    --过滤掉增加施法距离的操作
	--shoot.max_distance_operation = max_distance
    initDurationBuff(keys)

    local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot)
    ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
	shoot.particleID = particleID
	EmitSoundOn(keys.soundCast, shoot)
    moveShoot(keys, shoot, electricBallBoomCallBack, nil)
end

--技能爆炸,单次伤害
function electricBallBoomCallBack(shoot)
    electricBallRenderParticles(shoot) --爆炸粒子效果生成		  
	boomAOEOperation(shoot, electricBallAOEOperationCallback)
end

function electricBallRenderParticles(shoot)
	local newParticlesID = ParticleManager:CreateParticle(shoot.particles_boom, PATTACH_ABSORIGIN_FOLLOW , shoot)
	ParticleManager:SetParticleControlEnt(newParticlesID, shoot.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
end

function electricBallAOEOperationCallback(shoot,unit)
	local keys = shoot.keysTable
	local caster = keys.caster
	local ability = keys.ability
    local AbilityLevel = shoot.abilityLevel
    local playerID = caster:GetPlayerID()
    local hitTargetDebuff = keys.hitTargetDebuff
    local stunDebuff = keys.stunDebuff

	local damage = getApplyDamageValue(shoot) / 3
	

    local debuffDuration = ability:GetSpecialValueFor("debuff_duration") --debuff持续时间
    debuffDuration = getFinalValueOperation(playerID,debuffDuration,'control',AbilityLevel,nil)
    debuffDuration = getApplyControlValue(shoot, debuffDuration)
    --ability:ApplyDataDrivenModifier(caster, unit, hitTargetDebuff, {Duration = debuffDuration})
    unit:AddNewModifier( caster, ability, hitTargetDebuff, {Duration = debuffDuration} )
    local interval = 2
    local timeCount = 0
    Timers:CreateTimer(function()
        ApplyDamage({victim = unit, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType()})
        --ability:ApplyDataDrivenModifier(caster, unit, stunDebuff, {Duration = 1})
        unit:AddNewModifier( caster, ability, stunDebuff, {Duration = 1} )
        EmitSoundOn(keys.soundBoom, shoot)
        timeCount = timeCount + interval
        if timeCount < debuffDuration then
            return interval
        end
        return nil
    end)
end

