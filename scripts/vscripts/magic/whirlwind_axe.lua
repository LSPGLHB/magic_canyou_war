require('shoot_init')
require('skill_operation')
function createShoot(keys)
    local caster = keys.caster
    local ability = keys.ability
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
    ability:ApplyDataDrivenModifier(caster, caster, buffName, {Duration = buffDuration})
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
        creatSkillShootInit(keys,shoot,caster,max_distance,casterDirection)


        local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot)
        ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
        shoot.particleID = particleID
        EmitSoundOn(keys.soundCast, shoot)
        
        moveShoot(keys, shoot, whirlwindAxeBoomCallBack, nil)

        shootCount = shootCount + 1
        if shootCount == maxCount then
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



	ApplyDamage({victim = unit, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType()})

    if currentStack < bounds_damage_count then
        currentStack = currentStack + 1
        ability:ApplyDataDrivenModifier(caster, unit, hitTargetDebuff, {Duration = 5})  
        unit:SetModifierStackCount( hitTargetDebuff, abilityName, currentStack )
        EmitSoundOn(keys.soundBoomNM, shoot)
        whirlwindAxeRenderParticles(shoot) 
    else
        EmitSoundOn(keys.soundBoomMax, shoot)
        whirlwindAxeMaxRenderParticles(shoot) 
    end

    	
end

