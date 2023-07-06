require('shoot_init')
require('skill_operation')
function createShoot(keys)
    local caster = keys.caster
    local ability = keys.ability
    local skillPoint = ability:GetCursorPosition()
	local aoe_radius = ability:GetSpecialValueFor("aoe_radius") 
    local aoe_duration = ability:GetSpecialValueFor("aoe_duration")
    local casterPoint = caster:GetAbsOrigin()
    local max_distance = (skillPoint - casterPoint ):Length2D()
    local direction = (skillPoint - casterPoint):Normalized()
    local shoot = CreateUnitByName(keys.unitModel, casterPoint, true, nil, nil, caster:GetTeam())
    creatSkillShootInit(keys,shoot,caster,max_distance,direction)
    --过滤掉增加施法距离的操作
	shoot.max_distance_operation = max_distance
    initDurationBuff(keys)
	shoot.aoe_radius = aoe_radius
    shoot.aoe_duration = aoe_duration
    local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot)
    ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
	shoot.particleID = particleID
    shoot.boomDelay = ability:GetSpecialValueFor("boom_delay")
	EmitSoundOn(keys.soundCast, caster)
    moveShoot(keys, shoot, electricWallBoomCallBack, nil)
end

--技能爆炸,单次伤害
function electricWallBoomCallBack(shoot)
    local interval = 1
    electricWallDelayRenderParticles(shoot)
    electricWallRenderParticles(shoot) --爆炸粒子效果生成		  
    Timers:CreateTimer(shoot.boomDelay, function()
        if shoot.energyHealth ~= 0 then 
            durationAOEDamage(shoot, interval, electricWallDamageCallback)
            electricWallAOEIntervalCallBack(shoot)
        end
        return nil
    end)
end

function electricWallDelayRenderParticles(shoot)
	ParticleManager:SetParticleControl(shoot.particleID, 13, Vector(0, 1, 0))
end

function electricWallRenderParticles(shoot)
	local keys = shoot.keysTable
	local caster = keys.caster
	local radius = shoot.aoe_radius
    local duration = shoot.aoe_duration
	local particleBoom = ParticleManager:CreateParticle(keys.particles_boom, PATTACH_WORLDORIGIN, caster)
	local groundPos = GetGroundPosition(shoot:GetAbsOrigin(), shoot)
	ParticleManager:SetParticleControl(particleBoom, 3, groundPos)
	ParticleManager:SetParticleControl(particleBoom, 10, Vector(radius, 0, 0))
    ParticleManager:SetParticleControl(particleBoom, 11, Vector(duration, 0, 0))
end

function electricWallDamageCallback(shoot, unit, interval)
    local keys = shoot.keysTable
    local caster = keys.caster
    local shootPos = shoot:GetAbsOrigin()
    local unitPos = unit:GetAbsOrigin()
   
    local ability = keys.ability
    local duration = shoot.aoe_duration
	local playerID = caster:GetPlayerID()
    
    local damageTotal = getApplyDamageValue(shoot)
    local damage = damageTotal / (duration / interval)
	ApplyDamage({victim = unit, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType()})

    
end

function electricWallAOEIntervalCallBack(shoot)
    local keys = shoot.keysTable
    local caster = keys.caster
    local ability = keys.ability
    local AbilityLevel = shoot.abilityLevel
    local playerID = caster:GetPlayerID()
    local radius = shoot.aoe_radius
    local duration = shoot.aoe_duration
    local interval = 0.02
    local timeCount = 0 
    
    Timers:CreateTimer(0,function ()  
        shoot.tempHitUnits = {} 
        local aroundUnits = FindUnitsInRadius(casterTeam, 
										position,
										nil,
										radius,
										DOTA_UNIT_TARGET_TEAM_BOTH,
										DOTA_UNIT_TARGET_ALL,
										0,
										0,
										false)

        for k,unit in pairs(aroundUnits) do
            local newFlag = checkHitUnitToMark(shoot, unit, nil)
            if newFlag then
                --此处可以加aoe范围内的状态
            end

            --table.insert(shoot.tempHitUnits, unit)
        end

        local warningRadius = radius - 25
        local aroundUnitsSp2 = FindUnitsInRadius(casterTeam, 
										position,
										nil,
										warningRadius,
										DOTA_UNIT_TARGET_TEAM_BOTH,
										DOTA_UNIT_TARGET_ALL,
										0,
										0,
										false)

        for k,unit in pairs(aroundUnits) do
            table.insert(shoot.tempHitUnits, unit)
        end


        local oldArray = {}
		oldArray = shoot.hitUnits
		local newArray = {}
		newArray = shoot.tempHitUnits
		for i = 1, #oldArray do
			local flag = true
			for j = 1, #newArray do
				if oldArray[i] == newArray[j] then
					flag = false
				end
			end
			if flag then
                local hitTargetStun = keys.hitTargetStun
                local debuffDuration = ability:GetSpecialValueFor("debuff_duration") --debuff持续时间
                debuffDuration = getFinalValueOperation(playerID,debuffDuration,'control',AbilityLevel,nil)
                debuffDuration = getApplyControlValue(shoot, debuffDuration)
                ability:ApplyDataDrivenModifier(caster, unit, hitTargetStun, {Duration = debuffDuration})  
                local beatBackDistance = ability:GetSpecialValueFor("beat_back_distance")
                local beatBackSpeed = ability:GetSpecialValueFor("beat_back_speed") 
                beatBackUnit(keys,shoot,unit,beatBackSpeed,beatBackDistance,true)
			end
		end
		shoot.hitUnits = shoot.tempHitUnits

        
        timeCount = timeCount + interval
        if timeCount >= duration then
			return nil
		end   
    end)
end