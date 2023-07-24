require('shoot_init')
require('skill_operation')
function stepOne(keys)
    local caster = keys.caster
    local ability = keys.ability
    local skillPoint = ability:GetCursorPosition()  
    local casterPoint = caster:GetAbsOrigin()
    local max_distance = ability:GetSpecialValueFor("max_distance")

    local direction = (skillPoint - casterPoint):Normalized()

    local shoot = CreateUnitByName(keys.unitModel, casterPoint, true, nil, nil, caster:GetTeam())
    creatSkillShootInit(keys,shoot,caster,max_distance,direction)
   

    local ability_a_name	= keys.ability_a_name
    local ability_b_name	= keys.ability_b_name
    caster:SwapAbilities( ability_a_name, ability_b_name, false, true )
    caster.twice_ice_ball_on = 1
    local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot)
    ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
	shoot.particleID = particleID
	EmitSoundOn(keys.soundCast, caster)
    local casterBuff = keys.modifier_caster_stage_name
    ability:ApplyDataDrivenModifier(caster, caster, casterBuff, {Duration = 5})
    Timers:CreateTimer(5, function()
        if caster.twice_ice_ball_on == 1 then
            initStage(keys)
            if caster:HasModifier(casterBuff) then
                caster:RemoveModifierByName(casterBuff) 
            end
        end
        return nil
    end)

    moveShoot(keys, shoot, twiceIceBallBoomCallBackSp1, nil)
end

function stepTwo(keys)
    local caster = keys.caster
    local ability = keys.ability
    local skillPoint = ability:GetCursorPosition()
    local casterPoint = caster:GetAbsOrigin()
    local max_distance = ability:GetSpecialValueFor("max_distance")

    local direction = (skillPoint - casterPoint):Normalized()

    local shoot = CreateUnitByName(keys.unitModel, casterPoint, true, nil, nil, caster:GetTeam())
    creatSkillShootInit(keys,shoot,caster,max_distance,direction)

    --过滤掉增加施法距离的操作
	--shoot.max_distance_operation = max_distance
    initDurationBuff(keys)


    local ability_a_name	= keys.ability_a_name
    local ability_b_name	= keys.ability_b_name
    caster:SwapAbilities( ability_a_name, ability_b_name, true, false )
    caster.twice_ice_ball_on = 0
    local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot)
    ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
	shoot.particleID = particleID
	EmitSoundOn(keys.soundCast, caster)
    initStage(keys)
    local casterBuff = keys.modifier_caster_stage_name
    if caster:HasModifier(casterBuff) then
        caster:RemoveModifierByName(casterBuff) 
    end
    moveShoot(keys, shoot, twiceIceBallBoomCallBackSp2, nil)
end

function twiceIceBallBoomCallBackSp1(shoot)
	twiceIceBallBoomAOERenderParticles(shoot)
    boomAOEOperation(shoot, twiceIceBallAOEOperationCallbackSp1)
end

function twiceIceBallBoomCallBackSp2(shoot)
	twiceIceBallBoomAOERenderParticles(shoot)
    boomAOEOperation(shoot, twiceIceBallAOEOperationCallbackSp2)
end

function twiceIceBallBoomAOERenderParticles(shoot)
    local particlesName = shoot.particles_boom
	local newParticlesID = ParticleManager:CreateParticle(particlesName, PATTACH_ABSORIGIN_FOLLOW , shoot)
	ParticleManager:SetParticleControlEnt(newParticlesID, shoot.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
end

function twiceIceBallAOEOperationCallbackSp1(shoot,unit)
    local keys = shoot.keysTable
    local caster = keys.caster
	
	local ability = keys.ability

    local damage = getApplyDamageValue(shoot) * (6 / 18)
    ApplyDamage({victim = unit, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType()})

    local AbilityLevel = shoot.abilityLevel
    local hitTargetDebuff = keys.hitTargetDebuff
    local playerID = caster:GetPlayerID()

    local debuffDuration = ability:GetSpecialValueFor("debuff_duration") --debuff持续时间
    debuffDuration = getFinalValueOperation(playerID,debuffDuration,'control',AbilityLevel,nil)
    debuffDuration = getApplyControlValue(shoot, debuffDuration)
    ability:ApplyDataDrivenModifier(caster, unit, hitTargetDebuff, {Duration = debuffDuration})  

     
end

function twiceIceBallAOEOperationCallbackSp2(shoot,unit)
    local keys = shoot.keysTable
    local caster = keys.caster
	local ability = keys.ability

    local damage_by_distance = ability:GetSpecialValueFor("damage_by_distance")

    local damage = getApplyDamageValue(shoot) * (12 / 18) + (shoot.traveled_distance / damage_by_distance)
    ApplyDamage({victim = unit, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType()})

    
end






function LevelUpAbility(keys)
    local caster = keys.caster
	local this_ability = keys.ability
	local this_abilityName = this_ability:GetAbilityName()
	local this_abilityLevel = this_ability:GetLevel()
	-- The ability to level up
	local ability_b_name = keys.ability_b_name
	local ability_handle = caster:FindAbilityByName(ability_b_name)
	local ability_level = ability_handle:GetLevel()
	-- Check to not enter a level up loop
	if ability_level ~= this_abilityLevel then
		ability_handle:SetLevel(this_abilityLevel)
	end
end


function initStage(keys)
    local caster	= keys.caster
	local ability	= keys.ability

    local ability_a_name	= ability:GetAbilityName()
    local ability_b_name	= keys.ability_b_name
    caster:SwapAbilities( ability_a_name, ability_b_name, true, false )
end
