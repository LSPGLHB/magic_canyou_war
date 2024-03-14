require('shoot_init')
require('skill_operation')

fire_bottle_datadriven = class({})
function fire_bottle_datadriven:GetCastRange(v,t)
    local range = getRangeByName(self,'c')
    return range
end
function fire_bottle_datadriven:GetAOERadius()
	local aoe_radius = getAOERadiusByName(self,'c')
	return aoe_radius
end
function fire_bottle_datadriven:OnSpellStart()
    createShoot(self)
end

function createShoot(ability)
    local caster = ability:GetCaster()
	local magicName = ability:GetAbilityName()
    local keys = getMagicKeys(ability,magicName)

    keys.particles_nm =     "particles/11huoyaoping_shengcheng.vpcf"
    keys.soundCast =		"magic_fire_bottle_cast"
    
    keys.particles_power = 	"particles/11huoyaoping_jiaqiang.vpcf"
    keys.soundPower =		"magic_fire_power_up"

    keys.particles_weak = 	"particles/11huoyaoping_xueruo.vpcf"
    keys.soundWeak =		"magic_fire_power_down"
    
    keys.particles_boom = 	"particles/11huoyaopingbaozha.vpcf"
    keys.soundBoom =		"magic_fire_bottle_boom"
    
    keys.soundDuration =		"magic_fire_bottle_duration"
    keys.soundDurationDelay =   0.3

    local skillPoint = ability:GetCursorPosition()    
    local casterPoint = caster:GetAbsOrigin()
    local max_distance = (skillPoint - casterPoint ):Length2D()
    local direction = (skillPoint - casterPoint):Normalized()
    local shoot = CreateUnitByName(keys.unitModel, casterPoint, true, nil, nil, caster:GetTeam())
    creatSkillShootInit(keys,shoot,caster,max_distance,direction)

    --过滤掉增加施法距离的操作
	shoot.max_distance_operation = max_distance
    initDurationBuff(keys)

    local aoe_duration = ability:GetSpecialValueFor("aoe_duration")
    shoot.aoe_duration = aoe_duration

    local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot)
    ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
    shoot.particleID = particleID
    EmitSoundOn(keys.soundCast, caster)
    moveShoot(keys, shoot, fireBottleBoomCallBack, nil)
    caster.shootOver = 1
end

function fireBottleBoomCallBack(shoot)
    local keys = shoot.keysTable
    fireBottleDuration(shoot) --实现持续光环效果以及粒子效果
    EmitSoundOn(keys.soundBoom, shoot)
end

function fireBottleDuration(shoot)
    local interval = 0.5
    fireBottleRenderParticles(shoot)
    durationAOEDamage(shoot, interval, fireBottleDamageCallback)
end

function fireBottleRenderParticles(shoot)
    local keys = shoot.keysTable
    local caster = keys.caster
	--local ability = keys.ability
	local particleBoom = ParticleManager:CreateParticle(keys.particles_boom, PATTACH_WORLDORIGIN, caster)
    local groundPos = GetGroundPosition(shoot:GetAbsOrigin(), shoot)
	ParticleManager:SetParticleControl(particleBoom, 3, groundPos)
    ParticleManager:SetParticleControl(particleBoom, 10, Vector(shoot.aoe_radius, 1, 0))
    ParticleManager:SetParticleControl(particleBoom, 11, Vector(shoot.aoe_duration, 0, 0))
end

function fireBottleDamageCallback(shoot, unit, interval)
    local keys = shoot.keysTable
    local caster = keys.caster
    local shootPos = shoot:GetAbsOrigin()
    local unitPos = unit:GetAbsOrigin()
    local radius = shoot.aoe_radius
    local ability = keys.ability
    local duration = shoot.aoe_duration
    local damageTotal = getApplyDamageValue(shoot)
    local damage = damageTotal / (duration / interval)
    local distance = (shootPos - unitPos):Length2D()
    if distance < 0.5 * radius then
        damage = damage * 2
    end
	ApplyDamage({victim = unit, attacker = shoot, damage = damage, damage_type = ability:GetAbilityDamageType()})
end