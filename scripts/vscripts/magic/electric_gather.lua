require('shoot_init')
require('skill_operation')
function shootStartCharge(keys)
	--每次升级调用
	local caster = keys.caster
	local ability = keys.ability
	local counterModifierName = keys.modifierCountName
	local max_charges = ability:GetSpecialValueFor("max_charges") 
	local charge_replenish_time = ability:GetSpecialValueFor("charge_replenish_time")
	
	caster.electric_gather_max_charges = max_charges
	caster.electric_gather_charge_replenish_time = charge_replenish_time

	--子弹数刷新
	if caster.electric_gather_charges == nil then
		caster.electric_gather_cooldown = 0.0
		caster.electric_gather_charges = max_charges
	end

	ability:EndCooldown()
	caster:SetModifierStackCount( counterModifierName, caster, caster.electric_gather_charges )

	--上弹初始化
	if keys.ability:GetLevel() == 1 then
		ability:ApplyDataDrivenModifier( caster, caster, counterModifierName, {})
		caster.electric_gather_start_charge = false
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
		if caster.electric_gather_start_charge and caster.electric_gather_charges < caster.electric_gather_max_charges then
			local next_charge = caster.electric_gather_charges + 1
			caster:RemoveModifierByName( counterModifierName )
			if next_charge ~= caster.electric_gather_max_charges then
				ability:ApplyDataDrivenModifier( caster, caster, counterModifierName, { Duration = caster.electric_gather_charge_replenish_time } )
				shoot_start_cooldown( caster, caster.electric_gather_charge_replenish_time )
			else
				ability:ApplyDataDrivenModifier( caster, caster, counterModifierName, {} )
				caster.electric_gather_start_charge = false
			end
			-- Update stack
			caster:SetModifierStackCount( counterModifierName, caster, next_charge )
			caster.electric_gather_charges = next_charge
		end
		-- Check if max is reached then check every seconds if the charge is used
		if caster.electric_gather_charges < caster.electric_gather_max_charges then
			caster.electric_gather_start_charge = true
			return caster.electric_gather_charge_replenish_time
		else
			caster.electric_gather_start_charge = false
			return nil
		end
	end)
end

--充能用的冷却，每个技能需要独立一个字段使用，caster下的弹夹需要是唯一的
function shoot_start_cooldown(caster, charge_replenish_time)
	caster.electric_gather_cooldown = charge_replenish_time
	Timers:CreateTimer(function()
			local current_cooldown = caster.electric_gather_cooldown - 0.1
			if current_cooldown > 0.1 then
				caster.electric_gather_cooldown = current_cooldown
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




    local counterModifierName = keys.modifierCountName
    local max_charges = caster.electric_gather_max_charges
    local charge_replenish_time = caster.electric_gather_charge_replenish_time
    local next_charge = caster.electric_gather_charges - 1

    --满弹情况下开枪启动充能
    if caster.electric_gather_charges == max_charges then
        caster:RemoveModifierByName( counterModifierName )
        ability:ApplyDataDrivenModifier( caster, caster, counterModifierName, { Duration = charge_replenish_time } )
        createCharges(keys)
        shoot_start_cooldown( caster, charge_replenish_time )
    end
    caster:SetModifierStackCount( counterModifierName, caster, next_charge )
    caster.electric_gather_charges = next_charge
    --无弹后启动技能冷却
    if caster.electric_gather_charges == 0 then
        ability:StartCooldown(caster.electric_gather_cooldown)
    --else
    --    ability:EndCooldown()
    end

    initDurationBuff(keys)

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
	local speed = ability:GetSpecialValueFor("speed")
    local max_distance = ability:GetSpecialValueFor("max_distance")

	local timeCount = 0
	caster.electric_gather_send = 0
	shoot.traveled_back_distance = 0
	Timers:CreateTimer(function()

		if caster.electric_gather_send == 1 then
			shoot.speed = 0
			max_distance = max_distance + shoot.traveled_back_distance
			local shootDirection = shoot.direction * -1
			
			Timers:CreateTimer(0.15,function()
				EmitSoundOn(keys.soundCastSp2, shoot)
				creatSkillShootInit(keys,shoot,caster,max_distance,shootDirection)
				return nil
			end)
			return nil
		end

		shoot.speed = pull_back_distance * 2 / (charge_time*charge_time) * timeCount * 0.02
		shoot.traveled_back_distance = shoot.traveled_back_distance + shoot.speed
		timeCount = timeCount + charge_interval
		return charge_interval
	end)
	
	shoot.direction = shoot.direction * -1

	moveShoot(keys, shoot, electricGatherBoomCallBack, nil)
end

function electricGatherSend(keys)
	local caster = keys.caster
	caster.electric_gather_send = 1
end

function electricGatherChargeInit(keys)
	local caster = keys.caster
	local ability = keys.ability
	local charge_damage_per_interval = ability:GetSpecialValueFor("charge_damage_per_interval")
	ability.electric_gather_damage_bouns = 0.0
	ability.electric_gather_damage_bouns = ability.electric_gather_damage_bouns + charge_damage_per_interval

end

function electricGatherCharge(keys)
	local caster = keys.caster
	local ability = keys.ability
	local charge_damage_per_interval = ability:GetSpecialValueFor("charge_damage_per_interval")
	ability.electric_gather_damage_bouns = ability.electric_gather_damage_bouns + charge_damage_per_interval
end



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

    ApplyDamage({victim = unit, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType()})
end


