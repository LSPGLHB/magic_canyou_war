require('shoot_init')
require('skill_operation')
function createShoot(keys)
    local caster = keys.caster
    local ability = keys.ability
    local skillPoint = ability:GetCursorPosition()
    --local speed = ability:GetSpecialValueFor("speed")
	--local aoe_radius = ability:GetSpecialValueFor("aoe_radius") 
    local casterPoint = caster:GetAbsOrigin()
    local max_distance = ability:GetSpecialValueFor("max_distance") -- (skillPoint - casterPoint ):Length2D()
    local direction = (skillPoint - casterPoint):Normalized()
    initDurationBuff(keys)

    local interval = 0.5
    local shootCount = 0
    local maxCount = 5

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
        
        local shoot = CreateUnitByName(keys.unitModel, caster:GetAbsOrigin(), true, nil, nil, caster:GetTeam())
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


	ApplyDamage({victim = unit, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType()})
end

