require('shoot_init')
require('skill_operation')
thunder_spirit_datadriven = ({})
LinkLuaModifier( "modifier_thunder_spirit_caster_buff", "magic/modifiers/thunder_spirit_modifier_debuff.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL )

function thunder_spirit_datadriven:GetCastRange(v,t)
    local range = getRangeByName(self,'a')
    return range
end

function thunder_spirit_datadriven:OnSpellStart()
    createShoot(self)
end

function createShoot(ability)
    local caster = ability:GetCaster()
    local magicName = ability:GetAbilityName()
    local keys = getMagicKeys(ability,magicName)

    keys.particles_nm =      "particles/28leijingling_shengcheng.vpcf"
    keys.soundCast =			"magic_thunder_spirit_cast"  
    keys.particles_power = 	"particles/28leijingling_jiaqiang.vpcf"
    keys.soundPower =		"magic_thunder_power_up"
    keys.particles_weak = 	"particles/28leijingling_xueruo.vpcf"
    keys.soundWeak =			"magic_thunder_power_down"
    keys.particles_misfire = "particles/28leijingling_jiluo.vpcf"
    keys.soundMisfire =		"magic_thunder_mis_fire"
    keys.particles_miss =    "particles/28leijingling_xiaoshi.vpcf"
    keys.soundMiss =			"magic_thunder_miss"
    keys.particles_boom = 	"particles/28leijingling_mingzhong.vpcf"
    keys.soundBoom =			"magic_thunder_spirit_boom"
    keys.particles_boom_max = 	"particles/28leijingling_mingzhong_max.vpcf"
    keys.soundBoomMax =			"magic_thunder_spirit_boom_max"
    keys.modifier_caster_name =   "modifier_thunder_spirit_caster_buff"

    local skillPoint = ability:GetCursorPosition()
    local casterPoint = caster:GetAbsOrigin()
    local max_distance = ability:GetSpecialValueFor("max_distance") -- (skillPoint - casterPoint ):Length2D()
    local direction = (skillPoint - casterPoint):Normalized()
    initDurationBuff(keys)

    local interval = 0.5
    local shootCount = 0
    local maxCount = 5

    local buffName = keys.modifier_caster_name
    local buffDuration = interval * maxCount
    --ability:ApplyDataDrivenModifier(caster, caster, buffName, {Duration = buffDuration})
    caster:AddNewModifier(caster, ability, buffName, {Duration = buffDuration})
    Timers:CreateTimer(interval / 2, function()
        caster:StartGesture(ACT_DOTA_ATTACK)
        if shootCount == maxCount - 1 then
            return nil
        end
        return interval
    end)
    local shootCount = 1
    Timers:CreateTimer(interval, function()
        
        local shoot = CreateUnitByName(keys.unitModel, caster:GetAbsOrigin(), true, nil, nil, caster:GetTeam())
        shoot.shootCount = shootCount
        creatSkillShootInit(keys,shoot,caster,max_distance,direction)
        --过滤掉增加施法距离的操作
        --shoot.max_distance_operation = max_distance
        --shoot.aoe_radius = aoe_radius
        local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot)
        ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
        shoot.particleID = particleID
        EmitSoundOn(keys.soundCast, shoot)
        
        moveShoot(keys, shoot, thunderSpiritBoomCallBack, nil)

        shootCount = shootCount + 1
        if shootCount == maxCount then
            caster.shootOver = 1
            return nil
        end
        return interval
    end)
   
    
end

--技能爆炸,单次伤害
function thunderSpiritBoomCallBack(shoot)
   
	boomAOEOperation(shoot, AOEOperationCallback)
end

function thunderSpiritRenderParticles(shoot)
	local particlesName = shoot.particles_boom
	local newParticlesID = ParticleManager:CreateParticle(particlesName, PATTACH_ABSORIGIN_FOLLOW , shoot)
	ParticleManager:SetParticleControlEnt(newParticlesID, shoot.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
end

function thunderSpiritMaxRenderParticles(shoot)
    local keys = shoot.keysTable
	local particlesName = keys.particles_boom_max
	local newParticlesID = ParticleManager:CreateParticle(particlesName, PATTACH_ABSORIGIN_FOLLOW , shoot)
	ParticleManager:SetParticleControlEnt(newParticlesID, shoot.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
end

function AOEOperationCallback(shoot,unit)
	local keys = shoot.keysTable
	local caster = keys.caster
	local ability = keys.ability

	local damage = getApplyDamageValue(shoot) / 5

    local casterPoint = caster:GetAbsOrigin()
    local unitPoint = unit:GetAbsOrigin()

    --local max_distance = ability:GetSpecialValueFor("max_distance")
    local cu_distance = (unitPoint - casterPoint ):Length2D()
    local faceAngle = ability:GetSpecialValueFor("face_angle")

    local isFace = isFaceByFaceAngle(shoot, caster, faceAngle)

    if cu_distance <= 1200 and isFace then
        damage = damage * 2
        EmitSoundOn(keys.soundBoomMax, caster)
        thunderSpiritMaxRenderParticles(shoot)
    else
        thunderSpiritRenderParticles(shoot) --爆炸粒子效果生成		  
    end


	ApplyDamage({victim = unit, attacker = shoot, damage = damage, damage_type = ability:GetAbilityDamageType()})
end

