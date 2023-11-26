require('shoot_init')
require('skill_operation')
require('player_power')

function createShoot(keys)
    local caster = keys.caster
    local ability = keys.ability
    local skillPoint = ability:GetCursorPosition()
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