require('shoot_init')
require('skill_operation')
function shootStartCharge(keys)
	--每次升级调用
	local caster = keys.caster
	local ability = keys.ability
	local counterModifierName = keys.modifierCountName
	local max_charges = ability:GetSpecialValueFor("max_charges") 
	local charge_replenish_time = ability:GetSpecialValueFor("charge_replenish_time")
	
	caster.wind_arrow_max_charges = max_charges
	caster.wind_arrow_charge_replenish_time = charge_replenish_time

	--子弹数刷新
	if caster.wind_arrow_charges == nil then
		caster.wind_arrow_cooldown = 0.0
		caster.wind_arrow_charges = max_charges
	end

	ability:EndCooldown()
	caster:SetModifierStackCount( counterModifierName, caster, caster.wind_arrow_charges )

	--上弹初始化
	if keys.ability:GetLevel() == 1 then
		ability:ApplyDataDrivenModifier( caster, caster, counterModifierName, {})
		caster.wind_arrow_start_charge = false
		createCharges(keys)
	end
end

--启动上弹直到满弹
function createCharges(keys)
	local caster = keys.caster
	local ability = keys.ability
	local counterModifierName = keys.modifierCountName
	local playerID = caster:GetPlayerID()
	local charge_replenish_time = getFinalValueOperation(playerID,caster.wind_arrow_charge_replenish_time,'cooldown',nil,nil)

	Timers:CreateTimer(function()
		-- Restore charge
		if caster.wind_arrow_start_charge and caster.wind_arrow_charges < caster.wind_arrow_max_charges then
			local next_charge = caster.wind_arrow_charges + 1
			caster:RemoveModifierByName( counterModifierName )
			if next_charge ~= caster.wind_arrow_max_charges then
				ability:ApplyDataDrivenModifier( caster, caster, counterModifierName, { Duration = charge_replenish_time } )
				shoot_start_cooldown( caster, charge_replenish_time )
			else
				ability:ApplyDataDrivenModifier( caster, caster, counterModifierName, {} )
				caster.wind_arrow_start_charge = false
			end
			-- Update stack
			caster:SetModifierStackCount( counterModifierName, caster, next_charge )
			caster.wind_arrow_charges = next_charge
		end
		-- Check if max is reached then check every seconds if the charge is used
		if caster.wind_arrow_charges < caster.wind_arrow_max_charges then
			caster.wind_arrow_start_charge = true
			return charge_replenish_time
		else
			caster.wind_arrow_start_charge = false
			return nil
		end
	end)
end

--充能用的冷却，每个技能需要独立一个字段使用，caster下的弹夹需要是唯一的
function shoot_start_cooldown(caster, charge_replenish_time)
	caster.wind_arrow_cooldown = charge_replenish_time
	Timers:CreateTimer(function()
			local current_cooldown = caster.wind_arrow_cooldown - 0.1
			if current_cooldown > 0.1 then
				caster.wind_arrow_cooldown = current_cooldown
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


    local casterPoint = caster:GetAbsOrigin()
    local direction = (skillPoint - casterPoint):Normalized()

    local counterModifierName = keys.modifierCountName
    local max_charges = caster.wind_arrow_max_charges
    local playerID = caster:GetPlayerID()
	local charge_replenish_time = getFinalValueOperation(playerID,caster.wind_arrow_charge_replenish_time,'cooldown',nil,nil)

    local next_charge = caster.wind_arrow_charges - 1

    --满弹情况下开枪启动充能
    if caster.wind_arrow_charges == max_charges then
        caster:RemoveModifierByName( counterModifierName )
        ability:ApplyDataDrivenModifier( caster, caster, counterModifierName, { Duration = charge_replenish_time } )
        createCharges(keys)
        shoot_start_cooldown( caster, charge_replenish_time )
    end
    caster:SetModifierStackCount( counterModifierName, caster, next_charge )
    caster.wind_arrow_charges = next_charge
    --无弹后启动技能冷却
    if caster.wind_arrow_charges == 0 then
        ability:StartCooldown(caster.wind_arrow_cooldown)
    --else
        --ability:EndCooldown()
    end
    local shoot = CreateUnitByName(keys.unitModel, casterPoint, true, nil, nil, caster:GetTeam())
    creatSkillShootInit(keys,shoot,caster,max_distance,direction)

    local particleID = ParticleManager:CreateParticle(keys.particles_nm_sp1, PATTACH_ABSORIGIN_FOLLOW , shoot)
    ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
    shoot.particleID = particleID
    EmitSoundOn(keys.soundCastSp1, shoot)
    shoot.windSpeedUpUnit = {}
    shoot.intervalCallBack = windArrowIntervalCallBack
    moveShoot(keys, shoot, windArrowBoomCallBack, nil)
end

--技能爆炸,单次伤害
function windArrowBoomCallBack(shoot)
    windNetBoomRenderParticles(shoot)
    boomAOEOperation(shoot, windArrowAOEOperationCallback)
end

function windNetBoomRenderParticles(shoot)
	local particlesName = shoot.particles_boom
	local newParticlesID = ParticleManager:CreateParticle(particlesName, PATTACH_ABSORIGIN_FOLLOW , shoot)
	ParticleManager:SetParticleControlEnt(newParticlesID, shoot.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
end

function windArrowAOEOperationCallback(shoot,unit)
	local keys = shoot.keysTable
    local caster = keys.caster
	
	local ability = keys.ability
    local bounds_damage_percent =  ability:GetSpecialValueFor("bounds_damage_percent") / 100
    
    
    local damage = getApplyDamageValue(shoot) + unit:GetHealth() * bounds_damage_percent
    ApplyDamage({victim = unit, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType()})

	EmitSoundOn(keys.soundCastSp1, shoot)
end

function windArrowIntervalCallBack(shoot)
    local keys = shoot.keysTable
    local ability = keys.ability
    local shoot_speed = shoot.speed
    local wind_speed = ability:GetSpecialValueFor("wind_speed") * GameRules.speedConstant * 0.02
    local wind_speed_max = ability:GetSpecialValueFor("wind_speed_max") * GameRules.speedConstant * 0.02
    local wind_radius = ability:GetSpecialValueFor("wind_radius") 

    local caster = keys.caster
    local casterTeam = caster:GetTeam()
    local position = shoot:GetAbsOrigin()
    

    local aroundUnits = FindUnitsInRadius(casterTeam, 
										position,
										nil,
										wind_radius,
										DOTA_UNIT_TARGET_TEAM_BOTH,
										DOTA_UNIT_TARGET_ALL,
										0,
										0,
										false)
	for k,unit in pairs(aroundUnits) do
        local isTeamSkill = checkIsTeamSkill(shoot,unit)
        if isTeamSkill then
            
            local isHitFlag = true
            for i = 1, #shoot.windSpeedUpUnit do
                if shoot.windSpeedUpUnit[i] == unit then
                    isHitFlag = false  --如果已经击中过就不再击中
                    break
                end
            end
            if isHitFlag then
                table.insert(shoot.windSpeedUpUnit, unit)
                if shoot_speed < wind_speed_max then
                    shoot.speed = shoot_speed + wind_speed 
                    local new_particleID = ParticleManager:CreateParticle(keys.particles_nm_sp2, PATTACH_ABSORIGIN_FOLLOW , shoot)
		            ParticleManager:SetParticleControlEnt(new_particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
                    EmitSoundOn(keys.soundCastSp2, shoot)
                end
            end
        end
       
    end
end