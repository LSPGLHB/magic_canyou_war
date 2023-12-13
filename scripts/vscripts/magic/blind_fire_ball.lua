
require('shoot_init')
require('skill_operation')
require('player_power')
require('get_magic')
blind_fire_ball_pre_datadriven = class({})
blind_fire_ball_datadriven = class({})
LinkLuaModifier( "blind_fire_ball_datadriven_modifier_debuff", "magic/modifiers/blind_fire_ball_modifier_debuff.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL )
LinkLuaModifier( "blind_fire_ball_pre_datadriven_modifier_debuff", "magic/modifiers/blind_fire_ball_modifier_debuff.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL )
function blind_fire_ball_datadriven:OnSpellStart()
	creatShoot(self,'c')
end
function blind_fire_ball_pre_datadriven:OnSpellStart()
	creatShoot(self,'c')
end
function creatShoot(ability,magicName)
	local caster = ability:GetCaster()

    local keys = getMagicKeys(ability,magicName)
	magicListByName[magicName]['vision_radius'] = ability:GetSpecialValueFor("vision_radius")

	keys.particles_nm = "particles/31yinghuoqiu_shengcheng.vpcf"
    keys.soundCast = "magic_blind_fire_ball_cast"
	keys.particles_power = "particles/31yinghuoqiu_jiaqiang.vpcf"
	keys.soundPower = "magic_fire_power_up"
	keys.particles_weak ="particles/31yinghuoqiu_xueruo.vpcf"
	keys.soundWeak = "magic_fire_power_down"

    keys.particles_boom =  "particles/31yinghuoqiu_baozha.vpcf"
    keys.soundBoom = "magic_blind_fire_ball_boom"

	keys.particles_misfire = "particles/31yinghuoqiu_jiluo.vpcf"
	keys.soundMisfire =	"magic_fire_mis_fire"
	keys.particles_miss = "particles/31yinghuoqiu_xiaoshi.vpcf"
	keys.soundMiss = "magic_fire_miss"	

	keys.particles_defense = "particles/duobizhimangbuff2.vpcf"
	keys.soundDefense =      "magic_defence"
	keys.hitTargetDebuff = magicName.."_modifier_debuff"


	

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
        --ability:ApplyDataDrivenModifier(caster, unit, hitTargetDebuff, {Duration = debuffDuration})  
		unit:AddNewModifier( caster, ability, hitTargetDebuff, {Duration = debuffDuration} )
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