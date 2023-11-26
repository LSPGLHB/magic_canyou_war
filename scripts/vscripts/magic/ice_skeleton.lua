require('shoot_init')
require('skill_operation')
require('player_power')
function createShoot(keys)
    local caster = keys.caster
    local ability = keys.ability
    local skillPoint = ability:GetCursorPosition()
    --local speed = ability:GetSpecialValueFor("speed")
    local max_distance = ability:GetSpecialValueFor("max_distance")

    local casterPoint = caster:GetAbsOrigin()
    local direction = (skillPoint - casterPoint):Normalized()

    local shoot = CreateUnitByName(keys.unitModel, casterPoint, true, nil, nil, caster:GetTeam())
    creatSkillShootInit(keys,shoot,caster,max_distance,direction)
    --shoot.aoe_radius = aoe_radius
    local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot)
    ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
    shoot.particleID = particleID
    EmitSoundOn(keys.soundCast, shoot)
    shoot.intervalCallBack = iceSkeletonIntervalCallBack
    moveShoot(keys, shoot, iceSkeletonBoomCallback, nil)

end



--技能爆炸,单次伤害
function iceSkeletonBoomCallback(shoot)
		  
	boomAOEOperation(shoot, iceSkeletonAOEOperationCallback)
end

function iceSkeletonDefenseRenderParticles(shoot)
	local particlesName = shoot.particles_boom
	local newParticlesID = ParticleManager:CreateParticle(particlesName, PATTACH_ABSORIGIN_FOLLOW , shoot)
	ParticleManager:SetParticleControlEnt(newParticlesID, shoot.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
end

function iceSkeletonHitRenderParticles(shoot)
	local keys = shoot.keysTable
	local particlesName = keys.particles_boom_sp2
	local newParticlesID = ParticleManager:CreateParticle(particlesName, PATTACH_ABSORIGIN_FOLLOW , shoot)
	ParticleManager:SetParticleControlEnt(newParticlesID, shoot.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
end

function iceSkeletonAOEOperationCallback(shoot,unit)
	local keys = shoot.keysTable
    local caster = keys.caster
	local playerID = caster:GetPlayerID()
	local ability = keys.ability
	local bouns_damage_percentage = ability:GetSpecialValueFor("bouns_damage_percentage") / 100
	local damage = getApplyDamageValue(shoot) + (unit:GetMaxMana() - unit:GetMana()) * bouns_damage_percentage
	ApplyDamage({victim = unit, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType()})

    local faceAngle = ability:GetSpecialValueFor("face_angle")
    local isface = isFaceByFaceAngle(shoot, unit, faceAngle)
    if isface then
		iceSkeletonDefenseRenderParticles(shoot) --爆炸粒子效果生成	
        local defenceParticlesID =ParticleManager:CreateParticle(keys.particles_defense, PATTACH_CUSTOMORIGIN_FOLLOW , unit)
        ParticleManager:SetParticleControlEnt(defenceParticlesID, 3 , unit, PATTACH_CUSTOMORIGIN_FOLLOW, nil, shoot:GetAbsOrigin(), true)
        EmitSoundOn(keys.soundDefense, unit)
        Timers:CreateTimer(0.5, function()
                ParticleManager:DestroyParticle(defenceParticlesID, true)
                return nil
        end)
		
    else
		iceSkeletonHitRenderParticles(shoot) --爆炸粒子效果生成	
		local hitTargetDebuff = keys.hitTargetDebuff
		local playerID = caster:GetPlayerID()	
		local AbilityLevel = shoot.abilityLevel
		local debuffDuration = ability:GetSpecialValueFor("debuff_duration") --debuff持续时间
		--debuffDuration = getFinalValueOperation(playerID,debuffDuration,'control',AbilityLevel,nil)
		--debuffDuration = getApplyControlValue(shoot, debuffDuration)
		ability:ApplyDataDrivenModifier(caster, unit, hitTargetDebuff, {Duration = debuffDuration})  

		local unitPos = unit:GetAbsOrigin()
		local temp_x =math.random(-100,100) + unitPos.x
		local temp_y =math.random(-100,100) + unitPos.y
		local location = Vector(temp_x, temp_y ,0)
		Timers:CreateTimer(function()
			unitPos = unit:GetAbsOrigin()
			temp_x =math.random(-100,100) + unitPos.x
			temp_y =math.random(-100,100) + unitPos.y
			location = Vector(temp_x, temp_y ,0)
			if unit:HasModifier(hitTargetDebuff) then
				return 0.3
			end
			return nil
		end)	
		Timers:CreateTimer(function()
			unit:MoveToPosition(location)
			if unit:HasModifier(hitTargetDebuff) then
				return 0.05
			end
			return nil
		end)

    end

end

--技能追踪
function iceSkeletonIntervalCallBack(shoot)
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
				--shoot.speed = shoot.speed * 1.35
				shoot.traveled_distance = 0.5 * shoot.max_distance
			end
		end
	end

	if shoot.trackUnit ~= nil then
		shoot.direction = (shoot.trackUnit:GetAbsOrigin() - position):Normalized()
	end
end