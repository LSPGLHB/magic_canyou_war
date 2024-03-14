require('shoot_init')
require('skill_operation')
fire_spirit_pre_datadriven = ({})
fire_spirit_datadriven = ({})

function fire_spirit_pre_datadriven:GetCastRange(v,t)
    local range = getRangeByName(self,'b')
    return range
end

function fire_spirit_pre_datadriven:GetAOERadius()
	local aoe_radius = getAOERadiusByName(self,'b')
	return aoe_radius
end

function fire_spirit_pre_datadriven:OnSpellStart()
    createShoot(self)
end

function fire_spirit_datadriven:GetCastRange(v,t)
    local range = getRangeByName(self,'b')
    return range
end

function fire_spirit_datadriven:GetAOERadius()
	local aoe_radius = getAOERadiusByName(self,'b')
	return aoe_radius
end

function fire_spirit_datadriven:OnSpellStart()
    createShoot(self)
end

function createShoot(ability)
    local caster = ability:GetCaster()
    local magicName = ability:GetAbilityName()
    local keys = getMagicKeys(ability,magicName)

    keys.isDelay =			"1"
    keys.particles_nm =      "particles/21huojingling_shengcheng.vpcf"
    keys.soundCastSp1 =		"magic_fire_spirit_cast_sp1"
    keys.soundCastSp2 =		"magic_fire_spirit_cast_sp2"

    keys.particles_power = 	"particles/21huojingling_jiaqiang.vpcf"
    keys.soundPower =		"magic_fire_power_up"
    keys.particles_weak = 	"particles/21huojingling_xueruo.vpcf"
    keys.soundWeak =			"magic_fire_power_down"

    keys.particles_misfire = "particles/21huojingling_jiluo.vpcf"
    keys.soundMisfire =		"magic_fire_mis_fire"
    
    keys.particles_boom = 	"particles/21huojingling_baozha.vpcf"
    keys.soundBoom =			"magic_fire_spirit_boom"

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
    shoot.boomDelay = ability:GetSpecialValueFor("boom_delay")
	EmitSoundOn(keys.soundCastSp1, shoot)
    moveShoot(keys, shoot, fireSpiritBoomCallBack, nil)
    caster.shootOver = 1
end

--技能爆炸,单次伤害
function fireSpiritBoomCallBack(shoot)
    local keys = shoot.keysTable
    local ability = keys.ability
    shoot.hit_move_step = ability:GetSpecialValueFor("hit_move_step")
    fireSpiritDelayRenderParticles(shoot)
    
    Timers:CreateTimer(shoot.boomDelay, function()
        if shoot.energy_point ~= 0 then
            fireSpiritRenderParticles(shoot) --爆炸粒子效果生成		  
            boomAOEOperation(shoot, AOEOperationCallback)
        end
        return nil
    end)
    Timers:CreateTimer(function()
        powerShootParticleOperation(keys,shoot)
        if shoot.energy_point == 0 then
            return nil
        end
        return 0.02
    end)
end

function fireSpiritDelayRenderParticles(shoot)
    local keys = shoot.keysTable
    EmitSoundOn(keys.soundCastSp2, shoot)
	ParticleManager:SetParticleControl(shoot.particleID, 13, Vector(0, 1, 0))
end

function fireSpiritRenderParticles(shoot)
	local keys = shoot.keysTable
	local caster = keys.caster
	local radius = shoot.aoe_radius
	local particleBoom = ParticleManager:CreateParticle(keys.particles_boom, PATTACH_WORLDORIGIN, caster)
	local groundPos = GetGroundPosition(shoot:GetAbsOrigin(), shoot)
	ParticleManager:SetParticleControl(particleBoom, 3, groundPos)
	ParticleManager:SetParticleControl(particleBoom, 10, Vector(radius, 0, 0))
end

function AOEOperationCallback(shoot,unit)
	local keys = shoot.keysTable
	local caster = keys.caster
	local ability = keys.ability
	local damage = getApplyDamageValue(shoot)
	ApplyDamage({victim = unit, attacker = shoot, damage = damage, damage_type = ability:GetAbilityDamageType()})
end

