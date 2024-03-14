require('shoot_init')
require('skill_operation')
electric_wall_pre_datadriven = ({})
electric_wall_datadriven = ({})
LinkLuaModifier( "electric_wall_datadriven_modifier_debuff", "magic/modifiers/electric_wall_modifier_debuff.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL )

function electric_wall_pre_datadriven:GetCastRange(v,t)
    local range = getRangeByName(self,'a')
    return range
end

function electric_wall_pre_datadriven:GetAOERadius()
	local aoe_radius = getAOERadiusByName(self,'a')
	return aoe_radius
end

function electric_wall_pre_datadriven:OnSpellStart()
    createShoot(self)
end

function electric_wall_datadriven:GetCastRange(v,t)
    local range = getRangeByName(self,'a')
    return range
end

function electric_wall_datadriven:GetAOERadius()
	local aoe_radius = getAOERadiusByName(self,'a')
	return aoe_radius
end

function electric_wall_datadriven:OnSpellStart()
    createShoot(self)
end


function createShoot(ability)
    local caster = ability:GetCaster()
    local magicName = ability:GetAbilityName()
    local keys = getMagicKeys(ability,magicName)

    keys.isDelay =			1
    keys.particles_nm =     "particles/13dianliqiang_shengcheng.vpcf"
    keys.soundCast =		"magic_electric_wall_cast"
    
    keys.particles_power = 	"particles/13dianliqiang_jiaqiang.vpcf"
    keys.soundPower =		"magic_electric_power_up"
    keys.particles_weak = 	"particles/13dianliqiang_xueruo.vpcf"
    keys.soundWeak =		"magic_electric_power_down"

    keys.particles_misfire = "particles/13dianliqiang_jiluo.vpcf"
    keys.soundMisfire =		 "magic_electric_mis_fire"
    
    keys.particles_duration = 	"particles/13dianliqiang_baozha.vpcf"
    keys.soundDurationSp1 =		"magic_electric_wall_duration"

    keys.soundStun =		 "magic_electric_wall_stun"
    keys.hitTargetDebuff =   "electric_wall_datadriven_modifier_debuff"


    local skillPoint = ability:GetCursorPosition()
    local casterPoint = caster:GetAbsOrigin()
    local max_distance = (skillPoint - casterPoint ):Length2D()
    local direction = (skillPoint - casterPoint):Normalized()
    local shoot = CreateUnitByName(keys.unitModel, casterPoint, true, nil, nil, caster:GetTeam())
    creatSkillShootInit(keys,shoot,caster,max_distance,direction)
    --过滤掉增加施法距离的操作
	shoot.max_distance_operation = max_distance
    initDurationBuff(keys)
    

    local aoe_duration = ability:GetSpecialValueFor("aoe_duration")
    shoot.aoe_duration = aoe_duration

    
    local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot)
    ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
	shoot.particleID = particleID
    shoot.boomDelay = ability:GetSpecialValueFor("boom_delay")
	EmitSoundOn(keys.soundCast, shoot)
    moveShoot(keys, shoot, electricWallBoomCallBack, nil)

    caster.shootOver = 1

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
    local keys = shoot.keysTable
    Timers:CreateTimer(function()
        powerShootParticleOperation(keys,shoot)
        if shoot.energy_point == 0 then
            return nil
        end
        return 0.02
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
    damageCallback(shoot, unit, interval)
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
        local isEnemyNoSkill = checkIsEnemyHero(shoot,unit)
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
            local isEnemyNoSkill = checkIsEnemyHero(shoot,unit)
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
    local hitTargetDebuff = keys.hitTargetDebuff
    local debuffDuration = ability:GetSpecialValueFor("debuff_duration") --debuff持续时间
    debuffDuration = getFinalValueOperation(playerID,debuffDuration,'control',AbilityLevel,nil)
    debuffDuration = getApplyControlValue(shoot, debuffDuration)
    for i = 1, #oldArray do
        local flagSp1 = true
        for j = 1, #newArray do
            if oldArray[i] == newArray[j] then
                flagSp1 = false
            end
        end
        if flagSp1 then
            --ability:ApplyDataDrivenModifier(caster, oldArray[i], hitTargetDebuff, {Duration = debuffDuration}) 
            oldArray[i]:AddNewModifier(caster,ability,hitTargetDebuff, {Duration = debuffDuration})
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
            --ability:ApplyDataDrivenModifier(caster, newArray[x], hitTargetDebuff, {Duration = debuffDuration})  
            newArray[x]:AddNewModifier(caster,ability,hitTargetDebuff, {Duration = debuffDuration})
        end
    end
end