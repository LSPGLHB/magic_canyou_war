require('shoot_init')
require('skill_operation')
require('player_power')
function createShoot(keys)
    local caster = keys.caster
    local ability = keys.ability
    local skillPoint = ability:GetCursorPosition()
    local max_distance = ability:GetSpecialValueFor("max_distance")
	local catch_radius = ability:GetSpecialValueFor("catch_radius")
	local windAngle = ability:GetSpecialValueFor("wind_angle")
	local faceAngle = ability:GetSpecialValueFor("face_angle")
	local windSpeed = ability:GetSpecialValueFor("wind_speed") * 0.02 * GameRules.speedConstant

    local casterPoint = caster:GetAbsOrigin()
    local direction = (skillPoint - casterPoint):Normalized()

    local shoot = CreateUnitByName(keys.unitModel, casterPoint, true, nil, nil, caster:GetTeam())
    creatSkillShootInit(keys,shoot,caster,max_distance,direction)
    shoot.catch_radius = catch_radius
    local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot)
    ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
    shoot.particleID = particleID
    EmitSoundOn(keys.soundCast, shoot)
    moveShoot(keys, shoot, windDartBoomCallBack, nil)
	searchLockUnit(keys, caster, shoot, windAngle, faceAngle, windSpeed, keys.modifierLockDebuff)
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


function searchLockUnit(keys, caster, shoot, windAngle, faceAngle, windSpeed, modifierLockDebuff)
	local ability = keys.ability
	local casterTeam = caster:GetTeam()
	local casterPos = caster:GetAbsOrigin()
	local radius = shoot.max_distance
	local interval = 0.1
	local shootSpeed = shoot.speed
	local lockUnit
	local lessDistance = radius + 200

	local aroundUnits = FindUnitsInRadius(casterTeam, 
										casterPos,
										nil,
										radius,
										DOTA_UNIT_TARGET_TEAM_BOTH,
										DOTA_UNIT_TARGET_ALL,
										0,
										0,
										false)
	--找到符合条件最近的
	for k,unit in pairs(aroundUnits) do
		local isEnemyHero = checkIsEnemyHero(shoot,unit)
		if isEnemyHero and unit:IsHero() then 
			local isfaceSp1 = isFaceByFaceAngle(unit, shoot, windAngle)
			if isfaceSp1 then
				local distance = (unit:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D()
				if distance < lessDistance then
					lessDistance = distance
					lockUnit = unit
				end
			end
		end
	end
	

	if lockUnit ~= nil then
		ability:ApplyDataDrivenModifier(caster, lockUnit, modifierLockDebuff, {Duration = -1})
		Timers:CreateTimer(function()
			local isfaceSp2 = isFaceByFaceAngle(shoot, lockUnit, faceAngle)

			if isfaceSp2 and shoot.speed ~= shootSpeed then
				EmitSoundOn(keys.soundSpeedDown, shoot)
			end

			if not isfaceSp2 and shoot.speed ~= shootSpeed + windSpeed then
				EmitSoundOn(keys.soundSpeedUp, shoot)
			end

			if isfaceSp2 then
				shoot.speed = shootSpeed
				ParticleManager:SetParticleControl(shoot.particleID, 13, Vector(0, 0, 0))
			else
				shoot.speed = shootSpeed + windSpeed
				ParticleManager:SetParticleControl(shoot.particleID, 13, Vector(0, 1, 0))
			end

			if shoot.energy_point == 0 then
				if lockUnit:HasModifier(modifierLockDebuff) then
					lockUnit:RemoveModifierByName(modifierLockDebuff)
				end
				return nil
			end
			return interval
		end)
	end
end