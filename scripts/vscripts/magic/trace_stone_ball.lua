require('shoot_init')
require('skill_operation')
function shootStartCharge(keys)
	--每次升级调用
	local caster = keys.caster
	local ability = keys.ability
	local counterModifierName = keys.modifierCountName
	local max_charges = ability:GetSpecialValueFor("max_charges") 
	local charge_replenish_time = ability:GetSpecialValueFor("charge_replenish_time")
	
	caster.trace_stone_ball_max_charges = max_charges
	caster.trace_stone_ball_charge_replenish_time = charge_replenish_time

	--子弹数刷新
	if caster.trace_stone_ball_charges == nil then
		caster.trace_stone_ball_cooldown = 0.0
		caster.trace_stone_ball_charges = max_charges
	end

	ability:EndCooldown()
	caster:SetModifierStackCount( counterModifierName, caster, caster.trace_stone_ball_charges )

	--上弹初始化
	if keys.ability:GetLevel() == 1 then
		ability:ApplyDataDrivenModifier( caster, caster, counterModifierName, {})
		caster.trace_stone_ball_start_charge = false
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
		if caster.trace_stone_ball_start_charge and caster.trace_stone_ball_charges < caster.trace_stone_ball_max_charges then
			local next_charge = caster.trace_stone_ball_charges + 1
			caster:RemoveModifierByName( counterModifierName )
			if next_charge ~= caster.trace_stone_ball_max_charges then
				ability:ApplyDataDrivenModifier( caster, caster, counterModifierName, { Duration = caster.trace_stone_ball_charge_replenish_time } )
				shoot_start_cooldown( caster, caster.trace_stone_ball_charge_replenish_time )
			else
				ability:ApplyDataDrivenModifier( caster, caster, counterModifierName, {} )
				caster.trace_stone_ball_start_charge = false
			end
			-- Update stack
			caster:SetModifierStackCount( counterModifierName, caster, next_charge )
			caster.trace_stone_ball_charges = next_charge
		end
		-- Check if max is reached then check every seconds if the charge is used
		if caster.trace_stone_ball_charges < caster.trace_stone_ball_max_charges then
			caster.trace_stone_ball_start_charge = true
			return caster.trace_stone_ball_charge_replenish_time
		else
			caster.trace_stone_ball_start_charge = false
			return nil
		end
	end)
end

--充能用的冷却，每个技能需要独立一个字段使用，caster下的弹夹需要是唯一的
function shoot_start_cooldown(caster, charge_replenish_time)
	caster.trace_stone_ball_cooldown = charge_replenish_time
	Timers:CreateTimer(function()
			local current_cooldown = caster.trace_stone_ball_cooldown - 0.1
			if current_cooldown > 0.1 then
				caster.trace_stone_ball_cooldown = current_cooldown
				return 0.1
			else
				return nil
			end
		end)
end


function createTraceStoneBall(keys)
    local caster = keys.caster
    local ability = keys.ability
    local skillPoint = ability:GetCursorPosition()
    local speed = ability:GetSpecialValueFor("speed")
    local max_distance = ability:GetSpecialValueFor("max_distance")

    local casterPoint = caster:GetAbsOrigin()
    local direction = (skillPoint - casterPoint):Normalized()

    local counterModifierName = keys.modifierCountName
    local max_charges = caster.trace_stone_ball_max_charges
    local charge_replenish_time = caster.trace_stone_ball_charge_replenish_time
    local next_charge = caster.trace_stone_ball_charges - 1

    --满弹情况下开枪启动充能
    if caster.trace_stone_ball_charges == max_charges then
        caster:RemoveModifierByName( counterModifierName )
        ability:ApplyDataDrivenModifier( caster, caster, counterModifierName, { Duration = charge_replenish_time } )
        createCharges(keys)
        shoot_start_cooldown( caster, charge_replenish_time )
    end
    caster:SetModifierStackCount( counterModifierName, caster, next_charge )
    caster.trace_stone_ball_charges = next_charge
    --无弹后启动技能冷却
    if caster.trace_stone_ball_charges == 0 then
        ability:StartCooldown(caster.trace_stone_ball_cooldown)
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
    shoot.intervalCallBack = traceStoneBallIntervalCallBack
    moveShoot(keys, shoot, traceStoneBallBoomCallback, nil)

end





--技能爆炸,单次伤害
function traceStoneBallBoomCallback(shoot)
	traceStoneBallRenderParticles(shoot) --爆炸粒子效果生成		  
	boomAOEOperation(shoot, traceStoneBallAOEOperationCallback)
end

function traceStoneBallRenderParticles(shoot)
	local particlesName = shoot.particles_boom
	local newParticlesID = ParticleManager:CreateParticle(particlesName, PATTACH_ABSORIGIN_FOLLOW , shoot)
	ParticleManager:SetParticleControlEnt(newParticlesID, shoot.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
end

function traceStoneBallAOEOperationCallback(shoot,unit)
	local keys = shoot.keysTable
    local caster = keys.caster
	local playerID = caster:GetPlayerID()
	local ability = keys.ability

    local damage = getApplyDamageValue(shoot)
    ApplyDamage({victim = unit, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType()})
end

--技能追踪
function traceStoneBallIntervalCallBack(shoot)
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
			local unitEnergy = unit.energy_point
			local shootEnergy = shoot.energy_point
			if checkIsSkill(shoot,unit) then
				reinforceEach(unit,shoot,nil)
				reinforceEach(shoot,unit,nil)
			end

			if checkIsEnemyNoSkill(shoot,unit) then
				shoot.trackUnit = unit
				shoot.speed = shoot.speed * 2
			end
		end
	end

	if shoot.trackUnit ~= nil then
		shoot.direction = (shoot.trackUnit:GetAbsOrigin() - Vector(position.x, position.y, 0)):Normalized()
	end
end