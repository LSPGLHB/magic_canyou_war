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
	EmitSoundOn(keys.soundCast, shoot)
    moveShoot(keys, shoot, electricWallBoomCallBack, nil)
end

--技能爆炸,单次伤害
function electricWallBoomCallBack(shoot)
    local interval = 1
    electricWallDelayRenderParticles(shoot)
    electricWallRenderParticles(shoot) --爆炸粒子效果生成		  
    Timers:CreateTimer(shoot.boomDelay, function()
        if shoot.energy_point ~= 0 then 
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
	local particleBoom = ParticleManager:CreateParticle(keys.particles_duration, PATTACH_WORLDORIGIN, caster)
	local groundPos = GetGroundPosition(shoot:GetAbsOrigin(), shoot)
	ParticleManager:SetParticleControl(particleBoom, 3, groundPos)
	ParticleManager:SetParticleControl(particleBoom, 10, Vector(radius, 0, 0))
    ParticleManager:SetParticleControl(particleBoom, 11, Vector(duration, 0, 0))

    EmitSoundOn(keys.soundDurationSp1, shoot)
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
    --local AbilityLevel = shoot.abilityLevel
    --local playerID = caster:GetPlayerID()
    local radius = shoot.aoe_radius
    --local duration = shoot.aoe_duration
    local position = shoot:GetAbsOrigin()
    local casterTeam = caster:GetTeam()
    local interval = 0.05

    shoot.hitRangeUnits = {} 
    local warningRadiusSp1 = radius
    local aroundUnitsSp1 = FindUnitsInRadius(casterTeam, 
                                    position,
                                    nil,
                                    warningRadiusSp1,
                                    DOTA_UNIT_TARGET_TEAM_BOTH,
                                    DOTA_UNIT_TARGET_ALL,
                                    0,
                                    0,
                                    false)

    for k,unit in pairs(aroundUnitsSp1) do
        local isEnemyNoSkill = checkIsEnemyNoSkill(shoot,unit)
        if isEnemyNoSkill then
            table.insert(shoot.hitRangeUnits, unit)
        end
    end

    Timers:CreateTimer(0,function ()  
        shoot.tempHitRangeUnits = {}       
        local warningRadiusSp2 = radius
        local aroundUnitsSp2 = FindUnitsInRadius(casterTeam, 
										position,
										nil,
										warningRadiusSp2,
										DOTA_UNIT_TARGET_TEAM_BOTH,
										DOTA_UNIT_TARGET_ALL,
										0,
										0,
										false)

        for k,unit in pairs(aroundUnitsSp2) do
            local isEnemyNoSkill = checkIsEnemyNoSkill(shoot,unit)
            if isEnemyNoSkill then
                table.insert(shoot.tempHitRangeUnits, unit)
            end
        end

        electricWallAOEHitRange(shoot)

		shoot.hitRangeUnits = shoot.tempHitRangeUnits
        
        if shoot.isKillAOE == 1 then
			return nil
		end   
        return interval
    end)
end

--检查收否触碰电墙
function electricWallAOEHitRange(shoot)
    local keys = shoot.keysTable
    local caster = keys.caster
    local ability = keys.ability
    local AbilityLevel = shoot.abilityLevel
    local playerID = caster:GetPlayerID()
    local oldArray = {}
    oldArray = shoot.hitRangeUnits
    local newArray = {}
    newArray = shoot.tempHitRangeUnits
    --print("hitRangeUnits:",#oldArray,"-",#newArray)
    for i = 1, #oldArray do
        local flagSp1 = true
        for j = 1, #newArray do
            if oldArray[i] == newArray[j] then
                flagSp1 = false
            end
        end
        if flagSp1 then
            local hitTargetStun = keys.hitTargetStun
            local debuffDuration = ability:GetSpecialValueFor("debuff_duration") --debuff持续时间
            debuffDuration = getFinalValueOperation(playerID,debuffDuration,'control',AbilityLevel,nil)
            debuffDuration = getApplyControlValue(shoot, debuffDuration)
            ability:ApplyDataDrivenModifier(caster, oldArray[i], hitTargetStun, {Duration = debuffDuration})  
            --local beatBackDistance = ability:GetSpecialValueFor("beat_back_distance")
            --local beatBackSpeed = ability:GetSpecialValueFor("beat_back_speed") 
            --beatBackUnit(keys,shoot,oldArray[i],beatBackSpeed,beatBackDistance,true,false)
        end
    end

    for x = 1,#newArray do
        local flagSp2 = true
        for y = 1, #oldArray do
            if newArray[x] == oldArray[y] then
                flagSp2 = false
            end
        end
        if flagSp2 then
            local hitTargetStun = keys.hitTargetStun
            local debuffDuration = ability:GetSpecialValueFor("debuff_duration") --debuff持续时间
            debuffDuration = getFinalValueOperation(playerID,debuffDuration,'control',AbilityLevel,nil)
            debuffDuration = getApplyControlValue(shoot, debuffDuration)
            ability:ApplyDataDrivenModifier(caster, newArray[x], hitTargetStun, {Duration = debuffDuration})  
            --local beatBackDistance = ability:GetSpecialValueFor("beat_back_distance")
            --local beatBackSpeed = ability:GetSpecialValueFor("beat_back_speed") 
            --beatBackUnit(keys,shoot,newArray[x],beatBackSpeed,beatBackDistance,true,true)
        end
    end
end