require('shoot_init')
require('skill_operation')
function shootStartCharge(keys)
	--每次升级调用
	local caster = keys.caster
	local ability = keys.ability
	local counterModifierName = keys.modifierCountName
	local max_charges = ability:GetSpecialValueFor("max_charges") 
	local charge_replenish_time = ability:GetSpecialValueFor("charge_replenish_time")
	
	caster.wind_dart_max_charges = max_charges
	caster.wind_dart_charge_replenish_time = charge_replenish_time

	--子弹数刷新
	if caster.wind_dart_charges == nil then
		caster.wind_dart_cooldown = 0.0
		caster.wind_dart_charges = max_charges
	end

	ability:EndCooldown()
	caster:SetModifierStackCount( counterModifierName, caster, caster.wind_dart_charges )

	--上弹初始化
	if keys.ability:GetLevel() == 1 then
		ability:ApplyDataDrivenModifier( caster, caster, counterModifierName, {})
		caster.wind_dart_start_charge = false
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
		if caster.wind_dart_start_charge and caster.wind_dart_charges < caster.wind_dart_max_charges then
			local next_charge = caster.wind_dart_charges + 1
			caster:RemoveModifierByName( counterModifierName )
			if next_charge ~= caster.wind_dart_max_charges then
				ability:ApplyDataDrivenModifier( caster, caster, counterModifierName, { Duration = caster.wind_dart_charge_replenish_time } )
				shoot_start_cooldown( caster, caster.wind_dart_charge_replenish_time )
			else
				ability:ApplyDataDrivenModifier( caster, caster, counterModifierName, {} )
				caster.wind_dart_start_charge = false
			end
			-- Update stack
			caster:SetModifierStackCount( counterModifierName, caster, next_charge )
			caster.wind_dart_charges = next_charge
		end
		-- Check if max is reached then check every seconds if the charge is used
		if caster.wind_dart_charges < caster.wind_dart_max_charges then
			caster.wind_dart_start_charge = true
			return caster.wind_dart_charge_replenish_time
		else
			caster.wind_dart_start_charge = false
			return nil
		end
	end)
end

--充能用的冷却，每个技能需要独立一个字段使用，caster下的弹夹需要是唯一的
function shoot_start_cooldown(caster, charge_replenish_time)
	caster.wind_dart_cooldown = charge_replenish_time
	Timers:CreateTimer(function()
			local current_cooldown = caster.wind_dart_cooldown - 0.1
			if current_cooldown > 0.1 then
				caster.wind_dart_cooldown = current_cooldown
				return 0.1
			else
				return nil
			end
		end)
end


function createShoot(keys)
    local caster = keys.caster
    local ability = keys.ability
    local skillPoint = ability:GetCursorPosition()
    local speed = ability:GetSpecialValueFor("speed")
    local max_distance = ability:GetSpecialValueFor("max_distance")
	local catch_radius = ability:GetSpecialValueFor("catch_radius")
    local casterPoint = caster:GetAbsOrigin()
    local direction = (skillPoint - casterPoint):Normalized()

    local counterModifierName = keys.modifierCountName
    local max_charges = caster.wind_dart_max_charges
    local charge_replenish_time = caster.wind_dart_charge_replenish_time
    local next_charge = caster.wind_dart_charges - 1

    --满弹情况下开枪启动充能
    if caster.wind_dart_charges == max_charges then
        caster:RemoveModifierByName( counterModifierName )
        ability:ApplyDataDrivenModifier( caster, caster, counterModifierName, { Duration = charge_replenish_time } )
        createCharges(keys)
        shoot_start_cooldown( caster, charge_replenish_time )
    end
    caster:SetModifierStackCount( counterModifierName, caster, next_charge )
    caster.wind_dart_charges = next_charge
    --无弹后启动技能冷却
    if caster.wind_dart_charges == 0 then
        ability:StartCooldown(caster.wind_dart_cooldown)
    else
        --ability:EndCooldown()
    end
    local shoot = CreateUnitByName(keys.unitModel, casterPoint, true, nil, nil, caster:GetTeam())
    creatSkillShootInit(keys,shoot,caster,max_distance,direction)
    shoot.catch_radius = catch_radius
    local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot)
    ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
    shoot.particleID = particleID
    EmitSoundOn(keys.soundCast, shoot)
    moveShoot(keys, shoot, windDartBoomCallBack, nil)

end

--技能爆炸,单次伤害
function windDartBoomCallBack(shoot)
    
    boomAOEOperation(shoot, windDartAOEOperationCallback)
end

function windDartAOERenderParticles(shoot)
	local particlesName = shoot.particles_boom
    local newParticlesID = ParticleManager:CreateParticle(particlesName, PATTACH_ABSORIGIN_FOLLOW , shoot)
	ParticleManager:SetParticleControlEnt(newParticlesID, shoot.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
end

function windDartAOEOperationCallback(shoot,unit)
	local keys = shoot.keysTable
    local caster = keys.caster
	
	local ability = keys.ability
    local wind_damage_percent = ability:GetSpecialValueFor("wind_damage_percent") / 100

    local faceAngle = ability:GetSpecialValueFor("face_angle")
    local isface = isFaceByFaceAngle(shoot, unit, faceAngle)
    local damage = getApplyDamageValue(shoot)
    if isface then
        EmitSoundOn(keys.soundBoomS1, shoot)
    else
        damage = damage * (1 + wind_damage_percent)
        shoot.particles_boom = keys.particles_strike
        EmitSoundOn(keys.soundStrike, shoot)
    end
     
    ApplyDamage({victim = unit, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType()}) 
    windDartAOERenderParticles(shoot)
end

