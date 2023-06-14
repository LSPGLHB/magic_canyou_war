require('shoot_init')
require('skill_operation')
function shootStartCharge(keys)
	--每次升级调用
	local caster = keys.caster
	local ability = keys.ability
	local counterModifierName = keys.modifierCountName
	local max_charges = ability:GetSpecialValueFor("max_charges") 
	local charge_replenish_time = ability:GetSpecialValueFor("charge_replenish_time")
	
	caster.twine_soil_ball_max_charges = max_charges
	caster.twine_soil_ball_charge_replenish_time = charge_replenish_time

	--子弹数刷新
	if caster.twine_soil_ball_charges == nil then
		caster.twine_soil_ball_cooldown = 0.0
		caster.twine_soil_ball_charges = max_charges
	end

	ability:EndCooldown()
	caster:SetModifierStackCount( counterModifierName, caster, caster.twine_soil_ball_charges )

	--上弹初始化
	if keys.ability:GetLevel() == 1 then
		ability:ApplyDataDrivenModifier( caster, caster, counterModifierName, {})
		caster.twine_soil_ball_start_charge = false
		createCharges(keys)
	end
end

--启动上弹直到满弹
function createCharges(keys)
	local caster = keys.caster
	local ability = keys.ability
	local counterModifierName = keys.modifierCountName

	Timers:CreateTimer(function()
		-- Restore charge
		if caster.twine_soil_ball_start_charge and caster.twine_soil_ball_charges < caster.twine_soil_ball_max_charges then
			local next_charge = caster.twine_soil_ball_charges + 1
			caster:RemoveModifierByName( counterModifierName )
			if next_charge ~= caster.twine_soil_ball_max_charges then
				ability:ApplyDataDrivenModifier( caster, caster, counterModifierName, { Duration = caster.twine_soil_ball_charge_replenish_time } )
				shoot_start_cooldown( caster, caster.twine_soil_ball_charge_replenish_time )
			else
				ability:ApplyDataDrivenModifier( caster, caster, counterModifierName, {} )
				caster.twine_soil_ball_start_charge = false
			end
			-- Update stack
			caster:SetModifierStackCount( counterModifierName, caster, next_charge )
			caster.twine_soil_ball_charges = next_charge
		end
		-- Check if max is reached then check every seconds if the charge is used
		if caster.twine_soil_ball_charges < caster.twine_soil_ball_max_charges then
			caster.twine_soil_ball_start_charge = true
			return caster.twine_soil_ball_charge_replenish_time
		else
			caster.twine_soil_ball_start_charge = false
			return nil
		end
	end)
end

--充能用的冷却，每个技能需要独立一个字段使用，caster下的弹夹需要是唯一的
function shoot_start_cooldown( caster, charge_replenish_time )
	caster.twine_soil_ball_cooldown = charge_replenish_time
	Timers:CreateTimer( function()
			local current_cooldown = caster.twine_soil_ball_cooldown - 0.1
			if current_cooldown > 0.1 then
				caster.twine_soil_ball_cooldown = current_cooldown
				return 0.1
			else
				return nil
			end
		end
	)
end


function createTwineSoilBall(keys)
    local caster = keys.caster
    local ability = keys.ability
    local skillPoint = ability:GetCursorPosition()
    local speed = ability:GetSpecialValueFor("speed")
    local max_distance = ability:GetSpecialValueFor("max_distance")

    local casterPoint = caster:GetAbsOrigin()
    local direction = (skillPoint - casterPoint):Normalized()

    local counterModifierName = keys.modifierCountName
    local max_charges = caster.twine_soil_ball_max_charges
    local charge_replenish_time = caster.twine_soil_ball_charge_replenish_time
    local next_charge = caster.twine_soil_ball_charges - 1

    --满弹情况下开枪启动充能
    if caster.twine_soil_ball_charges == max_charges then
        caster:RemoveModifierByName( counterModifierName )
        ability:ApplyDataDrivenModifier( caster, caster, counterModifierName, { Duration = charge_replenish_time } )
        createCharges(keys)
        shoot_start_cooldown( caster, charge_replenish_time )
    end
    caster:SetModifierStackCount( counterModifierName, caster, next_charge )
    caster.twine_soil_ball_charges = next_charge
    --无弹后启动技能冷却
    if caster.twine_soil_ball_charges == 0 then
        ability:StartCooldown(caster.twine_soil_ball_cooldown)
    else
        ability:EndCooldown()
    end

    local shoot = CreateUnitByName(keys.unitModel, casterPoint, true, nil, nil, caster:GetTeam())
    creatSkillShootInit(keys,shoot,caster,max_distance,direction)
    --shoot.aoe_radius = aoe_radius
    local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot)
    ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
    shoot.particleID = particleID
    EmitSoundOn(keys.soundCast, shoot)
    moveShoot(keys, shoot, nil, twineSoilBallHitCallBack)

end

--技能爆炸,单次伤害
function twineSoilBallHitCallBack(keys, shoot, unit)
    passAOEOperation(keys, shoot,unit, passOperationCallback)
end


function passOperationCallback(keys,shoot,unit)
    local caster = keys.caster
	local playerID = caster:GetPlayerID()
	local ability = keys.ability
    local AbilityLevel = shoot.abilityLevel
    local debuffName = keys.hitTargetDebuff
    local damage = getApplyDamageValue(shoot)
    ApplyDamage({victim = unit, attacker = shoot, damage = damage, damage_type = ability:GetAbilityDamageType()})

    local debuffDuration = ability:GetSpecialValueFor("debuff_duration") --debuff持续时间
    debuffDuration = getFinalValueOperation(playerID,debuffDuration,'control',AbilityLevel,owner)
    debuffDuration = getApplyControlValue(shoot, debuffDuration)
    ability:ApplyDataDrivenModifier(caster, unit, debuffName, {Duration = debuffDuration})
end 