require('shoot_init')
require('skill_operation')

electric_arrow_datadriven = class({})

function electric_arrow_datadriven:GetCastRange(v,t)
    local range = getRangeByName(self,'c')
    return range
end

function electric_arrow_datadriven:GetAOERadius()
	local aoe_radius = getAOERadiusByName(self,'c')
	return aoe_radius
end

function electric_arrow_datadriven:OnSpellStart()
    createShoot(self)
end

function createShoot(ability)
    local caster = ability:GetCaster()
    local magicName = ability:GetAbilityName()
    local keys = getMagicKeys(ability,magicName)


    keys.particles_nm=      "particles/38dianjian_shengcheng.vpcf"
    keys.soundCastSp1=		"magic_electric_arrow_cast_sp1"
    keys.soundCastSp2=		"magic_electric_arrow_cast_sp2"
    
    keys.particles_power= 	"particles/38dianjian_jiaqiang.vpcf"
    keys.soundPower=		"magic_electric_power_up"
    keys.particles_weak= 	"particles/38dianjian_xueruo.vpcf"
    keys.soundWeak=			"magic_electric_power_down"

    keys.particles_misfire= "particles/38dianjian_jiluo.vpcf"
    keys.soundMisfire=		"magic_electric_mis_fire"
    keys.particles_miss=    "particles/38dianjian_xiaoshi.vpcf"
    keys.soundMiss=			"magic_electric_miss"
    
    keys.particles_boom= 	"particles/38dianjian_mingzhong.vpcf"
    keys.soundBoom =		"magic_electric_arrow_boom"

    local skillPoint = ability:GetCursorPosition()
    local casterPoint = caster:GetAbsOrigin()
    local max_distance = ability:GetSpecialValueFor("max_distance") -- (skillPoint - casterPoint ):Length2D()

    local direction = (skillPoint - casterPoint):Normalized()
    --casterPoint = casterPoint + direction * 50
    initDurationBuff(keys)

    local shoot = CreateUnitByName(keys.unitModel, casterPoint, true, nil, nil, caster:GetTeam())
    creatSkillShootInit(keys,shoot,caster,max_distance,direction)
    --过滤掉增加施法距离的操作
    --shoot.max_distance_operation = max_distance
    --shoot.aoe_radius = aoe_radius
    local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot)
    ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
    shoot.particleID = particleID
    EmitSoundOn(keys.soundCastSp1, shoot)

    local send_delay = ability:GetSpecialValueFor("send_delay")
    shoot.speed = 0
    moveShoot(keys, shoot, electricArrowBoomCallBack, nil)
    caster.shootOver = 1
    Timers:CreateTimer(send_delay, function()
        EmitSoundOn(keys.soundCastSp2, shoot)
        local AbilityLevel = shoot.abilityLevel
        local playerID = caster:GetPlayerID()
        local speedBase = ability:GetSpecialValueFor("speed")
        local speedBuffName = 'ability_speed'
        shoot.speed = getFinalValueOperation(playerID,speedBase,speedBuffName,AbilityLevel,nil) * GameRules.speedConstant * 0.02
    end) 
end

--技能爆炸,单次伤害
function electricArrowBoomCallBack(shoot)
    electricArrowRenderParticles(shoot)
	boomAOEOperation(shoot, electricArrowAOEOperationCallback)
end

function electricArrowRenderParticles(shoot)
	local particlesName = shoot.particles_boom
	local newParticlesID = ParticleManager:CreateParticle(particlesName, PATTACH_ABSORIGIN_FOLLOW , shoot)
	ParticleManager:SetParticleControlEnt(newParticlesID, shoot.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
end


function electricArrowAOEOperationCallback(shoot,unit)
	local keys = shoot.keysTable
	local caster = keys.caster
	local ability = keys.ability
    local damage_percent_sp = ability:GetSpecialValueFor("damage_percent_sp")
    local damage_bouns = (unit:GetMaxHealth() - unit:GetHealth()) * (damage_percent_sp / 100)
	local damage = getApplyDamageValue(shoot) + damage_bouns
	ApplyDamage({victim = unit, attacker = shoot, damage = damage, damage_type = ability:GetAbilityDamageType()})
end

