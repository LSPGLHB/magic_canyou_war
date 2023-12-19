require('shoot_init')
require('skill_operation')
require('player_power')
LinkLuaModifier( "modifier_electric_gather_channel_datadriven", "magic/modifiers/electric_gather_modifier.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL )
electric_gather_pre_datadriven = class({})
electric_gather_datadriven = class({})

function electric_gather_pre_datadriven:GetCastRange(v,t)
    local range = getRangeByName(self,'b')
    return range
end

function electric_gather_pre_datadriven:GetAOERadius()
	local aoe_radius = getAOERadiusByName(self,'b')
	return aoe_radius
end

function electric_gather_pre_datadriven:OnSpellStart()
    createShoot(self)
end

function electric_gather_pre_datadriven:OnChannelInterrupted()
	electricGatherSend(self)
end

function electric_gather_pre_datadriven:OnChannelFinish()
	electricGatherSend(self)
end

function electric_gather_datadriven:GetCastRange(v,t)
    local range = getRangeByName(self,'b')
    return range
end

function electric_gather_datadriven:GetAOERadius()
	local aoe_radius = getAOERadiusByName(self,'b')
	return aoe_radius
end

function electric_gather_datadriven:OnSpellStart()
    createShoot(self)
end

function electric_gather_datadriven:OnChannelInterrupted()
	electricGatherSend(self)
end

function electric_gather_datadriven:OnChannelFinish()
	electricGatherSend(self)
end

function createShoot(ability)
    local caster = ability:GetCaster()
	--local ability = self:GetAbility()
	local magicName = ability:GetAbilityName()
    local keys = getMagicKeys(ability,magicName)

	keys.particles_nm =      "particles/08xulishandian_shengcheng.vpcf"
	keys.soundCastSp1 =		"magic_electric_gather_cast_sp1"
	keys.soundCastSp2 =		"magic_electric_gather_cast_sp2"
	
	keys.particles_power = 	"particles/08xulishandian_jiaqiang.vpcf"
	keys.soundPower =	"magic_electric_power_up"
	keys.particles_weak = 	"particles/08xulishandian_xueruo.vpcf"
	keys.soundWeak =	"magic_electric_power_down"
	
	keys.particles_boom = 	"particles/08xulishandian_mingzhong.vpcf"
	keys.soundBoom =			"magic_electric_gather_boom"

	keys.particles_misfire = "particles/08xulishandian_jiluo.vpcf"
	keys.soundMisfire =		"magic_electric_mis_fire"
	keys.particles_miss =    "particles/08xulishandian_xiaoshi.vpcf"
	keys.soundMiss =		"magic_electric_miss"

	keys.modifier_caster_channel_name = "modifier_electric_gather_channel_datadriven"

    local skillPoint = ability:GetCursorPosition()
    local speed = ability:GetSpecialValueFor("speed")
    local max_distance = ability:GetSpecialValueFor("max_distance")

    local casterPoint = caster:GetAbsOrigin()
    local direction = (skillPoint - casterPoint):Normalized()


    local shootPosTable ={}
    local angle23 = 0.45 * math.pi

    local newX2 = math.cos(math.atan2(direction.y, direction.x) - angle23)
    local newY2 = math.sin(math.atan2(direction.y, direction.x) - angle23)
    local newX3 = math.cos(math.atan2(direction.y, direction.x) + angle23)
    local newY3 = math.sin(math.atan2(direction.y, direction.x) + angle23)
    local direction2 = Vector(newX2, newY2, direction.z)
    local direction3 = Vector(newX3, newY3, direction.z)

    local shootPos2 = casterPoint + direction2 * 60
    table.insert(shootPosTable,shootPos2)
    local shootPos3 = casterPoint + direction3 * 60
    table.insert(shootPosTable,shootPos3)

    initDurationBuff(keys)

	caster:AddNewModifier( caster, ability, keys.modifier_caster_channel_name, {Duration = -1})

	caster.electric_gather_send = 0
    ability.electric_gather_damage_bouns = 0.0
    local charge_time = ability:GetSpecialValueFor("charge_time")
    local charge_damage_per_interval = ability:GetSpecialValueFor("charge_damage_per_interval")
    local charge_interval = 0.1
    Timers:CreateTimer(function()
        if caster.electric_gather_send == 0 then
            ability.electric_gather_damage_bouns = ability.electric_gather_damage_bouns + charge_damage_per_interval
            --print("ga:"..ability.electric_gather_damage_bouns)
            return charge_interval
        else
            return nil
        end
    end)

    for i = 1, 2, 1 do
        local shootPos = shootPosTable[i]
        local shoot = CreateUnitByName(keys.unitModel, shootPos, true, nil, nil, caster:GetTeam())
        shootPos = Vector(shootPos.x,shootPos.y,shootPos.z+100)
        shoot:SetAbsOrigin(shootPos)
        local shootDirection = (skillPoint - shoot:GetAbsOrigin()):Normalized()
        creatSkillShootInit(keys,shoot,caster,max_distance,shootDirection)
        --shoot.aoe_radius = aoe_radius
        local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot)
        ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
        shoot.particleID = particleID
        EmitSoundOn(keys.soundCastSp1, shoot)

		moveElectricGatherSp1(keys,shoot)
   
    end

end

function moveElectricGatherSp1(keys,shoot)
	local caster = keys.caster
	local ability = keys.ability
	local pull_back_distance = ability:GetSpecialValueFor("pull_back_distance") 
	local charge_time = ability:GetSpecialValueFor("charge_time") 
	local charge_interval =  ability:GetSpecialValueFor("charge_interval")
    local max_distance = ability:GetSpecialValueFor("max_distance")

	local playerID = caster:GetPlayerID()
	local speedBase = ability:GetSpecialValueFor("speed")

	local timeCount = 0
	
	shoot.traveled_back_distance = 0
	Timers:CreateTimer(function()

		if caster.electric_gather_send == 1 then
			shoot.speed = 0
			max_distance = max_distance + shoot.traveled_back_distance
			local shootDirection = shoot.direction * -1
			
			Timers:CreateTimer(charge_time/2,function()
				EmitSoundOn(keys.soundCastSp2, shoot)
				creatSkillShootInit(keys,shoot,caster,max_distance,shootDirection)
				return nil
			end)
			return nil
		end
		--local maxSpeed = getFinalValueOperation(playerID,speedBase,'ability_speed',shoot.abilityLevel,nil) * GameRules.speedConstant * 0.02
		timeCount = timeCount + charge_interval

		shoot.speed = pull_back_distance * 2 / (charge_time * charge_time) *  (charge_time - timeCount) * 0.02

		--print(timeCount)
		shoot.traveled_back_distance = shoot.traveled_back_distance + shoot.speed
		
		return charge_interval
	end)
	
	shoot.direction = shoot.direction * -1

	moveShoot(keys, shoot, electricGatherBoomCallBack, nil)
end

function electricGatherSend(self)
	--print("electricGatherSendelectricGatherSendelectricGatherSend")
	local caster = self:GetCaster()
	caster.electric_gather_send = 1
	caster:RemoveModifierByName("modifier_electric_gather_channel_datadriven")
end

--[[
function electricGatherChargeInit(self)
	--local caster = keys.caster
	local ability = self:GetAbility()
	--local charge_damage_per_interval = ability:GetSpecialValueFor("charge_damage_per_interval")
	ability.electric_gather_damage_bouns = 0.0
	--ability.electric_gather_damage_bouns = ability.electric_gather_damage_bouns + charge_damage_per_interval

end

function electricGatherCharge(self)
	--local caster = keys.caster
	local ability = self:GetAbility()
	local charge_damage_per_interval = ability:GetSpecialValueFor("charge_damage_per_interval")
	ability.electric_gather_damage_bouns = ability.electric_gather_damage_bouns + charge_damage_per_interval
end]]



function electricGatherBoomCallBack(shoot)
	electricGatherBoomAOERenderParticles(shoot)
    boomAOEOperation(shoot, electricGatherAOEOperationCallback)
end
function electricGatherBoomAOERenderParticles(shoot)
	local particlesName = shoot.particles_boom
	local newParticlesID = ParticleManager:CreateParticle(particlesName, PATTACH_ABSORIGIN_FOLLOW , shoot)
	ParticleManager:SetParticleControlEnt(newParticlesID, shoot.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
end

function electricGatherAOEOperationCallback(shoot,unit)
	local keys = shoot.keysTable
    local caster = keys.caster
	local ability = keys.ability
	--print("electricGatherAOEOperationCallback:",ability.electric_gather_damage_bouns)
    local damage = (getApplyDamageValue(shoot)  + ability.electric_gather_damage_bouns) / 2
	--print("damage:"..damage)
    ApplyDamage({victim = unit, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType()})
end


