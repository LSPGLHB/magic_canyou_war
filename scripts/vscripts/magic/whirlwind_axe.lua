require('shoot_init')
require('skill_operation')
whirlwind_axe_datadriven = ({})
LinkLuaModifier( "whirlwind_axe_datadriven_modifier_debuff", "magic/modifiers/whirlwind_axe_modifier_debuff.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL )
LinkLuaModifier( "modifier_whirlwind_axe_caster_buff", "magic/modifiers/whirlwind_axe_modifier_debuff.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL )

function whirlwind_axe_datadriven:GetCastRange(v,t)
    local range = getRangeByName(self,'a')
    return range
end

function whirlwind_axe_datadriven:OnSpellStart()
    createShoot(self)
end

function createShoot(ability)
    local caster = ability:GetCaster()
    local magicName = ability:GetAbilityName()
    local keys = getMagicKeys(ability,magicName)

    keys.particles_nm =      "particles/45feifu_shengcheng.vpcf"
    keys.soundCast =			"magic_whirlwind_axe_cast"
    keys.particles_power = 	"particles/45feifu_jiaqiang.vpcf"
    keys.soundPower =		"magic_wind_power_up"
    keys.particles_weak = 	"particles/45feifu_xueruo.vpcf"
    keys.soundWeak =			"magic_wind_power_down"
    keys.particles_misfire = "particles/45feifu_jiluo.vpcf"
    keys.soundMisfire =		"magic_wind_mis_fire"
    keys.particles_miss =    "particles/45feifu_xiaoshi.vpcf"
    keys.soundMiss =			"magic_wind_miss"
    keys.particles_boom = 	"particles/45feifu_mingzhong.vpcf"
    keys.soundBoomNM =			"magic_whirlwind_axe_boom"
    keys.particles_boom_max = 	"particles/45feifu_mingzhong_max.vpcf"
    keys.soundBoomMax =			"magic_whirlwind_axe_boom_max"
    keys.modifier_caster_hit_debuff =     "whirlwind_axe_datadriven_modifier_debuff"
    keys.modifier_caster_name =   "modifier_whirlwind_axe_caster_buff"

    local skillPoint = ability:GetCursorPosition()
    local casterPoint = caster:GetAbsOrigin()
    local max_distance = ability:GetSpecialValueFor("max_distance") 
    local sendDirection = (skillPoint - casterPoint):Normalized()
    caster:SetForwardVector(sendDirection)
    
    initDurationBuff(keys)

    local interval = 0.2
    local shootCount = 0
    local maxCount = ability:GetSpecialValueFor("shoot_count")

    local buffName = keys.modifier_caster_name
    local buffDuration = interval * maxCount
    --ability:ApplyDataDrivenModifier(caster, caster, buffName, {Duration = buffDuration})
    caster:AddNewModifier(caster,ability,buffName, {Duration = buffDuration})
    --caster.shootOver = 0
    Timers:CreateTimer(interval / 2, function()
        caster:StartGesture(ACT_DOTA_ATTACK)
        if shootCount == maxCount - 1 then
            return nil
        end
        return interval
    end)
    
    Timers:CreateTimer(interval, function()
        local casterDirection = caster:GetForwardVector()
        local shoot = CreateUnitByName(keys.unitModel, caster:GetAbsOrigin(), true, nil, nil, caster:GetTeam())
        shoot.shootCount = shootCount
        creatSkillShootInit(keys,shoot,caster,max_distance,casterDirection)

        local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot)
        ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
        shoot.particleID = particleID
        
        EmitSoundOn(keys.soundCast, shoot)
        
        moveShoot(keys, shoot, whirlwindAxeBoomCallBack, nil)

        shootCount = shootCount + 1
        if shootCount == maxCount then
            caster.shootOver = 1
            print(caster.shootOver)
            return nil
        end
        return interval
    end)
    
    
end

--技能爆炸,单次伤害
function whirlwindAxeBoomCallBack(shoot)
	boomAOEOperation(shoot, AOEOperationCallback)
end

function whirlwindAxeRenderParticles(shoot)
	local particlesName = shoot.particles_boom
	local newParticlesID = ParticleManager:CreateParticle(particlesName, PATTACH_ABSORIGIN_FOLLOW , shoot)
	ParticleManager:SetParticleControlEnt(newParticlesID, shoot.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
end

function whirlwindAxeMaxRenderParticles(shoot)
    local keys = shoot.keysTable
	local particlesName = keys.particles_boom_max
	local newParticlesID = ParticleManager:CreateParticle(particlesName, PATTACH_ABSORIGIN_FOLLOW , shoot)
	ParticleManager:SetParticleControlEnt(newParticlesID, shoot.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
end

function AOEOperationCallback(shoot,unit)
	local keys = shoot.keysTable
	local caster = keys.caster
	local ability = keys.ability
    local maxCount = ability:GetSpecialValueFor("shoot_count")
    local hitTargetDebuff = keys.modifier_caster_hit_debuff
    local bounds_damage = ability:GetSpecialValueFor("bounds_damage")
	
    local bounds_damage_count = ability:GetSpecialValueFor("bounds_damage_count")
    local abilityName = caster:FindAbilityByName(ability:GetAbilityName())
	local currentStack = unit:GetModifierStackCount(hitTargetDebuff, abilityName)

    local damage = getApplyDamageValue(shoot) / maxCount + currentStack * bounds_damage

	ApplyDamage({victim = unit, attacker = shoot, damage = damage, damage_type = ability:GetAbilityDamageType()})

    if currentStack < bounds_damage_count then
        currentStack = currentStack + 1
        --ability:ApplyDataDrivenModifier(caster, unit, hitTargetDebuff, {Duration = 5})  
        unit:AddNewModifier(caster,ability,hitTargetDebuff, {Duration = 5})
        unit:SetModifierStackCount( hitTargetDebuff, abilityName, currentStack )
        EmitSoundOn(keys.soundBoomNM, shoot)
        whirlwindAxeRenderParticles(shoot) 
    else
        EmitSoundOn(keys.soundBoomMax, shoot)
        whirlwindAxeMaxRenderParticles(shoot) 
    end

    	
end

