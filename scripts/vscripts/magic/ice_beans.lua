require('shoot_init')
require('skill_operation')
function stageOne (keys)
    local caster	= keys.caster
	local ability	= keys.ability
    local modifierStageName	= keys.modifier_stage_a_name
	local chargeCount	= ability:GetSpecialValueFor("charge_count")

    --[[
    pfx = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN_FOLLOW, caster )
	caster.fire_spirits_pfx			= pfx
    ]]
    caster.fire_spirits_numSpirits	= chargeCount
	caster:SetModifierStackCount( modifierStageName, ability, chargeCount )

    local ability_b_name	= keys.ability_b_name
	local ability_a_name	= ability:GetAbilityName()
	caster:SwapAbilities( ability_a_name, ability_b_name, false, true )

    initDurationBuff(keys)
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

--[[
	local pfx = caster.fire_spirits_pfx
	ParticleManager:DestroyParticle( pfx, false )
]]
	-- Swap main ability
	local ability_a_name	= ability:GetAbilityName()
	local ability_b_name	= keys.ability_b_name
	caster:SwapAbilities( ability_a_name, ability_b_name, true, false )
end


function LaunchFire(keys)
    local caster	= keys.caster
	local ability	= keys.ability
	local modifierName	= keys.modifier_stage_a_name
	local skillPoint = ability:GetCursorPosition()
	local casterPoint = caster:GetAbsOrigin()
	--local casterDirection = caster:GetForwardVector()
	local speed = ability:GetSpecialValueFor("speed")
	local shootCount =  ability:GetSpecialValueFor("shoot_count")
	local max_distance = ability:GetSpecialValueFor("max_distance")
	local direction = (skillPoint - casterPoint ):Normalized() 
	local ability_a_name = caster:FindAbilityByName( keys.ability_a_name )

	local currentStack	= caster:GetModifierStackCount( modifierName, ability_a_name )
	currentStack = currentStack - 1
	
	caster:SetModifierStackCount( modifierName, ability_a_name, currentStack )
	local tempCount = 0

	Timers:CreateTimer(0,function ()
		local shoot = CreateUnitByName(keys.unitModel, casterPoint, true, nil, nil, caster:GetTeam())
		creatSkillShootInit(keys,shoot,caster,max_distance,direction)
		local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot)
		ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
		shoot.particleID = particleID
		EmitSoundOn(keys.soundCast, caster)
		moveShoot(keys, shoot, iceBeansHitCallBack, nil)
		tempCount = tempCount+1
		if tempCount == shootCount then
			return nil
		end
		return 0.3
	end)
	-- Update the particle 
    --[[
	local pfx = caster.fire_spirits_pfx
	ParticleManager:SetParticleControl( pfx, 1, Vector( currentStack, 0, 0 ) )
	for i=1, caster.fire_spirits_numSpirits do
		local radius = 0
		if i <= currentStack then
			radius = 1
		end

		ParticleManager:SetParticleControl( pfx, 8+i, Vector( radius, 0, 0 ) )
	end
  ]]
	-- Remove the stack modifier if all the spirits has been launched.
	if currentStack == 0 then
		caster:RemoveModifierByName( modifierName )
	end
  
end



--技能爆炸,单次伤害
function iceBeansHitCallBack(keys,shoot)
    ParticleManager:DestroyParticle(shoot.particleID, true) --子弹特效消失
    boomAOEOperation(keys, shoot, AOEOperationCallback)
	--shootKill(keys, shoot, "hit")
end


function AOEOperationCallback(keys,shoot,unit)
    local caster = keys.caster
	local playerID = caster:GetPlayerID()
	local ability = keys.ability
    local AbilityLevel = shoot.abilityLevel
    local debuffName = keys.modifierDebuffName
    local damage = getApplyDamageValue(shoot)
    ApplyDamage({victim = unit, attacker = shoot, damage = damage, damage_type = ability:GetAbilityDamageType()})

    local debuffDuration = ability:GetSpecialValueFor("debuff_duration") --debuff持续时间
    debuffDuration = getFinalValueOperation(playerID,debuffDuration,'control',AbilityLevel,owner)
    debuffDuration = getApplyControlValue(shoot, debuffDuration)

    ability:ApplyDataDrivenModifier(caster, unit, debuffName, {Duration = debuffDuration})


end 