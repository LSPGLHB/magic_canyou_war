require('shoot_init')
require('skill_operation')
require('player_power')
function shootStartCharge(keys)
	--每次升级调用--萤火球
	local caster = keys.caster
	local ability = keys.ability
	local counterModifierName = keys.modifierCountName
	local max_charges = ability:GetSpecialValueFor("max_charges") 
	local charge_replenish_time = ability:GetSpecialValueFor("charge_replenish_time")
	
	caster.blind_fire_ball_max_charges = max_charges
	caster.blind_fire_ball_charge_replenish_time = charge_replenish_time

	--子弹数刷新
	if caster.blind_fire_ball_charges == nil then
		caster.blind_fire_ball_cooldown = 0.0
		caster.blind_fire_ball_charges = max_charges
	end
	print("shootStartCharge:"..counterModifierName)
	--ability:EndCooldown()
	caster:SetModifierStackCount( counterModifierName, caster, caster.blind_fire_ball_charges )

	--上弹初始化
	if keys.ability:GetLevel() == 1 then
		ability:ApplyDataDrivenModifier( caster, caster, counterModifierName, {})
		caster.blind_fire_ball_start_charge = false
		createCharges(keys)
	end
end

--启动上弹直到满弹
function createCharges(keys)
	local caster = keys.caster
	local ability = keys.ability
	local counterModifierName = keys.modifierCountName
	local playerID = caster:GetPlayerID()
	local charge_replenish_time = getFinalValueOperation(playerID,caster.blind_fire_ball_charge_replenish_time,'cooldown',nil,nil)

	Timers:CreateTimer(function()
		-- Restore charge
		if caster.blind_fire_ball_start_charge and caster.blind_fire_ball_charges < caster.blind_fire_ball_max_charges then
			local next_charge = caster.blind_fire_ball_charges + 1
			caster:RemoveModifierByName( counterModifierName )
			if next_charge ~= caster.blind_fire_ball_max_charges then
				ability:ApplyDataDrivenModifier( caster, caster, counterModifierName, { Duration = charge_replenish_time } )
				shoot_start_cooldown( caster, charge_replenish_time )
			else
				ability:ApplyDataDrivenModifier( caster, caster, counterModifierName, {} )
				caster.blind_fire_ball_start_charge = false
			end
			-- Update stack
			caster:SetModifierStackCount( counterModifierName, caster, next_charge )
			caster.blind_fire_ball_charges = next_charge
		end
		-- Check if max is reached then check every seconds if the charge is used
		if caster.blind_fire_ball_charges < caster.blind_fire_ball_max_charges then
			caster.blind_fire_ball_start_charge = true
			return charge_replenish_time
		else
			caster.blind_fire_ball_start_charge = false
			return nil
		end
	end)
end

--充能用的冷却，每个技能需要独立一个字段使用，caster下的弹夹需要是唯一的
function shoot_start_cooldown(caster, charge_replenish_time)
	caster.blind_fire_ball_cooldown = charge_replenish_time
	Timers:CreateTimer(function()
			local current_cooldown = caster.blind_fire_ball_cooldown - 0.1
			if current_cooldown > 0.1 then
				caster.blind_fire_ball_cooldown = current_cooldown
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
    local max_distance = ability:GetSpecialValueFor("max_distance")

    local casterPoint = caster:GetAbsOrigin()
    local direction = (skillPoint - casterPoint):Normalized()
	local playerID = caster:GetPlayerID()
    local counterModifierName = keys.modifierCountName
    local max_charges = caster.blind_fire_ball_max_charges
    local charge_replenish_time = getFinalValueOperation(playerID,caster.blind_fire_ball_charge_replenish_time,'cooldown',nil,nil)
    local next_charge = caster.blind_fire_ball_charges - 1

    --满弹情况下开枪启动充能
    if caster.blind_fire_ball_charges == max_charges then
        caster:RemoveModifierByName( counterModifierName )
        ability:ApplyDataDrivenModifier( caster, caster, counterModifierName, { Duration = charge_replenish_time } )
        createCharges(keys)
        shoot_start_cooldown( caster, charge_replenish_time )
    end
    caster:SetModifierStackCount( counterModifierName, caster, next_charge )
    caster.blind_fire_ball_charges = next_charge
    --无弹后启动技能冷却
    if caster.blind_fire_ball_charges == 0 then
        ability:StartCooldown(caster.blind_fire_ball_cooldown)

    end
    local shoot = CreateUnitByName(keys.unitModel, casterPoint, true, nil, nil, caster:GetTeam())
    creatSkillShootInit(keys,shoot,caster,max_distance,direction)
    --shoot.aoe_radius = aoe_radius
    local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot)
    ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
    shoot.particleID = particleID
    EmitSoundOn(keys.soundCast, shoot)
	shoot.intervalCallBack = blindFireBallIntervalCallBack
    moveShoot(keys, shoot, blindFireBallBoomCallBack, nil)

end

function blindFireBallBoomCallBack(shoot)
	blindFireBallBoomAOERenderParticles(shoot)
    boomAOEOperation(shoot, blindFireBallAOEOperationCallback)
end
function blindFireBallBoomAOERenderParticles(shoot)
	local particlesName = shoot.particles_boom
	local newParticlesID = ParticleManager:CreateParticle(particlesName, PATTACH_ABSORIGIN_FOLLOW , shoot)
	ParticleManager:SetParticleControlEnt(newParticlesID, shoot.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
end

function blindFireBallAOEOperationCallback(shoot,unit)
	local keys = shoot.keysTable
    local caster = keys.caster
	local playerID = caster:GetPlayerID()
	local ability = keys.ability
    local AbilityLevel = shoot.abilityLevel
    local hitTargetDebuff = keys.hitTargetDebuff
    local faceAngle = ability:GetSpecialValueFor("face_angle")
    local damage = getApplyDamageValue(shoot)
    local isface = isFaceByFaceAngle(shoot, unit, faceAngle)

    if isface then
        ApplyDamage({victim = unit, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType()})
        local debuffDuration = ability:GetSpecialValueFor("debuff_duration") --debuff持续时间
		debuffDuration = getFinalValueOperation(playerID,debuffDuration,'control',AbilityLevel,nil)
    	debuffDuration = getApplyControlValue(shoot, debuffDuration)
        ability:ApplyDataDrivenModifier(caster, unit, hitTargetDebuff, {Duration = debuffDuration})  
    else
        local defenceParticlesID =ParticleManager:CreateParticle(keys.particles_defense, PATTACH_OVERHEAD_FOLLOW , unit)
        ParticleManager:SetParticleControlEnt(defenceParticlesID, 3 , unit, PATTACH_OVERHEAD_FOLLOW, nil, shoot:GetAbsOrigin(), true)
        EmitSoundOn(keys.soundDefense, unit)
        Timers:CreateTimer(0.5, function()
                ParticleManager:DestroyParticle(defenceParticlesID, true)
                return nil
        end)
    end
end

--技能追踪
function blindFireBallIntervalCallBack(shoot)

	local keys = shoot.keysTable
	local caster = keys.caster
	local ability = keys.ability
	local casterTeam = caster:GetTeam()
	local position=shoot:GetAbsOrigin()
	local searchRadius = ability:GetSpecialValueFor("search_range")
	if shoot.trackUnit == nil then
		local aroundUnits = FindUnitsInRadius(casterTeam, 
											position,
											nil,
											searchRadius,
											DOTA_UNIT_TARGET_TEAM_BOTH,
											DOTA_UNIT_TARGET_ALL,
											0,
											0,
											false)

		for k,unit in pairs(aroundUnits) do
			--local unitEnergy = unit.energy_point
			--local shootEnergy = shoot.energy_point
			if checkIsEnemyHeroNoMagicStone(shoot,unit) then
				shoot.trackUnit = unit

				
				shoot.position = shoot:GetAbsOrigin()
				--shoot.traveled_distance =  0.5 * shoot.max_distance
				
				
			end
		end
	end

	--print("ooo:",shoot.traveled_distance)
	if shoot.trackUnit ~= nil then
		shoot.direction = (shoot.trackUnit:GetAbsOrigin() - position):Normalized()
	end

end