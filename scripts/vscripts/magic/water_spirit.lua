require('shoot_init')
require('skill_operation')
water_spirit_datadriven = ({})
water_spirit_pre_datadriven = ({})
LinkLuaModifier( "water_spirit_datadriven_modifier_debuff", "magic/modifiers/water_spirit_modifier_debuff.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL )

function water_spirit_pre_datadriven:GetCastRange(v,t)
    local range = getRangeByName(self,'b')
    return range
end

function water_spirit_pre_datadriven:GetAOERadius()
	local aoe_radius = getAOERadiusByName(self,'b')
	return aoe_radius
end

function water_spirit_pre_datadriven:OnSpellStart()
    createShoot(self)
end

function water_spirit_datadriven:GetCastRange(v,t)
    local range = getRangeByName(self,'b')
    return range
end

function water_spirit_datadriven:GetAOERadius()
	local aoe_radius = getAOERadiusByName(self,'b')
	return aoe_radius
end

function water_spirit_datadriven:OnSpellStart()
    createShoot(self)
end

function createShoot(ability)
    local caster = ability:GetCaster()
    local magicName = ability:GetAbilityName()
    local keys = getMagicKeys(ability,magicName)

    keys.particles_nm =      "particles/09shuijingling_shengcheng.vpcf"
    keys.soundCastSp1 =		"magic_water_spirit_cast_sp1"
    keys.soundCastSp2 =		"magic_water_spirit_cast_sp2"   
    keys.particles_power = 	"particles/09shuijingling_jiaqiang.vpcf"
    keys.soundPower =		"magic_water_power_up"
    keys.particles_weak = 	"particles/09shuijingling_xueruo.vpcf"
    keys.soundWeak =			"magic_water_power_down"
    keys.particles_misfire = "particles/09shuijingling_jiluo.vpcf"
    keys.soundMisfire =		"magic_water_mis_fire" 
    keys.particles_boom = 	"particles/09shuijingling_baozha.vpcf"
    keys.soundBoom =			"magic_water_spirit_boom"
    keys.hitTargetDebuff =   "water_spirit_datadriven_modifier_debuff"

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
    moveShoot(keys, shoot, waterSpiritBoomCallBack, nil)
    caster.shootOver = 1
end

--技能爆炸,单次伤害
function waterSpiritBoomCallBack(shoot)
    local keys = shoot.keysTable
    local ability = keys.ability
    shoot.hit_move_step = ability:GetSpecialValueFor("hit_move_step")
    waterSpiritDelayRenderParticles(shoot)
    Timers:CreateTimer(shoot.boomDelay, function()
        if shoot.energy_point ~= 0 then
            waterSpiritRenderParticles(shoot) --爆炸粒子效果生成		  
            boomAOEOperation(shoot, waterSpiritAOEOperationCallback)
        end
        return nil
    end)
    local keys = shoot.keysTable
    Timers:CreateTimer(function()
        powerShootParticleOperation(keys,shoot)
        if shoot.energy_point == 0 then
            return nil
        end
        return 0.02
    end)
end

function waterSpiritDelayRenderParticles(shoot)
    local keys = shoot.keysTable
    EmitSoundOn(keys.soundCastSp2, shoot)
	ParticleManager:SetParticleControl(shoot.particleID, 13, Vector(0, 1, 0))
end

function waterSpiritRenderParticles(shoot)
	local keys = shoot.keysTable
	local caster = keys.caster
	local radius = shoot.aoe_radius
	local particleBoom = ParticleManager:CreateParticle(keys.particles_boom, PATTACH_WORLDORIGIN, caster)
	local groundPos = GetGroundPosition(shoot:GetAbsOrigin(), shoot)
	ParticleManager:SetParticleControl(particleBoom, 3, groundPos)
	ParticleManager:SetParticleControl(particleBoom, 1, Vector(radius, 0, 0))
end

function waterSpiritAOEOperationCallback(shoot,unit)
	local keys = shoot.keysTable
	local caster = keys.caster
	local ability = keys.ability
    local playerID = caster:GetPlayerID()	
    local AbilityLevel = shoot.abilityLevel
    local hitTargetDebuff = keys.hitTargetDebuff
    
	local damage = getApplyDamageValue(shoot)
	ApplyDamage({victim = unit, attacker = shoot, damage = damage, damage_type = ability:GetAbilityDamageType()})

    local debuffDuration = ability:GetSpecialValueFor("debuff_duration") --debuff持续时间
    debuffDuration = getFinalValueOperation(playerID,debuffDuration,'control',AbilityLevel,nil)
    debuffDuration = getApplyControlValue(shoot, debuffDuration)
    --ability:ApplyDataDrivenModifier(caster, unit, hitTargetDebuff, {Duration = debuffDuration})  --特效有问题，没有无限循环
    unit:AddNewModifier(caster,ability,hitTargetDebuff, {Duration = debuffDuration})
end

