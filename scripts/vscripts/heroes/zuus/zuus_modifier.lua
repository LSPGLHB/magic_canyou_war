modifier_zuus_passive = ({})

function modifier_zuus_passive:IsHidden()
    return true
end

function modifier_zuus_passive:DeclareFunctions()
	local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE
	}
	return funcs
end

function modifier_zuus_passive:OnCreated()
    if IsServer() then
        local unit = self:GetParent()
        --unit.zuusPassiveUnitArray = {}  
    end
end

function modifier_zuus_passive:OnTakeDamage(keys)
    local shoot = keys.attacker
    if IsServer() and shoot.owner == self:GetParent() then
        local particlesName = "particles/qianghuage_dandao.vpcf"
        local ability = self:GetAbility()
        local caster = self:GetParent()
        local unit = keys.unit --受伤的人
        if unit.zuusPassiveUnitArray == nil then
            unit.zuusPassiveUnitArray = {}
        end
        local isContain = checkContainsArrayValue(unit.zuusPassiveUnitArray, shoot)
        if not isContain then
            --print(shoot:GetName())
            table.insert(unit.zuusPassiveUnitArray,shoot)

            local keys = {}
            keys.caster = caster
            keys.ability = ability
            zuusPassiveBuffRefresh(shoot.owner, ability)
            local particleID = ParticleManager:CreateParticle("particles/qianghuage_dandao.vpcf", PATTACH_ABSORIGIN_FOLLOW, unit)
            ParticleManager:SetParticleControl(particleID, 0, shoot.owner:GetAbsOrigin())
            ParticleManager:SetParticleControl(particleID, 1, shoot:GetAbsOrigin())

            unit.zuusPassiveParticleID = particleID
            
            local stackCount = caster.zuusPassiveStackCount
            local ability_speed_up_percent = ability:GetSpecialValueFor("ability_speed_up_percent") * stackCount
            local damage_up_percent = ability:GetSpecialValueFor("damage_up_percent") * stackCount
            local aoe_radius =  ability:GetSpecialValueFor("aoe_radius")
            local aroundUnits = FindUnitsInRadius(caster:GetTeam(), 
                                                    shoot:GetAbsOrigin(),
                                                    nil,
                                                    aoe_radius,
                                                    DOTA_UNIT_TARGET_TEAM_BOTH,
                                                    DOTA_UNIT_TARGET_ALL,
                                                    0,
                                                    0,
                                                    false)
            for _, value in ipairs(aroundUnits) do
                if value:GetUnitLabel() == GameRules.skillLabel and value.owner:GetPlayerID() == caster:GetPlayerID() and value.energy_point > 0 then
                    value.speed = value.speed * (1 + ability_speed_up_percent / 100)
                    value.damage = value.damage * (1 + damage_up_percent / 100)
                end
            end

            EmitSoundOn("scene_voice_zuus_passive", unit)
        end
    end
end

function zuusPassiveBuffRefresh(caster, ability)
    local stackCount = 0
    local modifierName = "modifier_zuus_cast_buff"
    local max_stack = ability:GetSpecialValueFor("max_stack")
    local keys = {}
    keys.caster = caster
    keys.ability = ability
    if caster:HasModifier(modifierName) then
        stackCount = caster:GetModifierStackCount( modifierName, caster )  
        caster:RemoveModifierByName(modifierName)
    end
    local power_up_duration = ability:GetSpecialValueFor("power_up_duration")
    caster:AddNewModifier(caster, ability, modifierName, {Duration = power_up_duration})  
    if stackCount < max_stack then
        stackCount = stackCount + 1 
    end
    caster:SetModifierStackCount(modifierName, caster, stackCount)
    caster.zuusPassiveStackCount = stackCount
    local vx = 0
    local vy = 0
    local vz = 0
    if stackCount >= 1 then
        vx = 1
        if stackCount >= 2 then
            vy = 1
            if stackCount >= 3 then
                vz = 1
            end
        end
    end
    local castParticleID = ParticleManager:CreateParticle("particles/qianghuage_zishen.vpcf", PATTACH_POINT_FOLLOW, caster)
    ParticleManager:SetParticleControl(castParticleID, 0, caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(castParticleID, 1, Vector(vx,vy,vz))
    caster.zuusCastParticleID =castParticleID
    --[[
    Timers:CreateTimer(1,function()
        ParticleManager:DestroyParticle(castParticleID, true)
    end)]]

    refreshZuusBuff(keys,true)
end


modifier_zuus_cast_buff = ({})

function modifier_zuus_cast_buff:IsBuff()
    return true
end

function modifier_zuus_cast_buff:OnCreated()
    if IsServer() then
        local unit = self:GetParent()
        unit.zuusPassiveStackCount = 0
    end
end

function modifier_zuus_cast_buff:OnDestroy()
    if IsServer() then
        local unit = self:GetParent()

        local keys = {}
        keys.caster = unit
        keys.ability = self:GetAbility()
        refreshZuusBuff(keys,false)
        if unit.zuusCastParticleID ~= nil then
            ParticleManager:DestroyParticle(unit.zuusCastParticleID, true)
        end
        if unit.zuusPassiveParticleID ~= nil then
            ParticleManager:DestroyParticle(unit.zuusPassiveParticleID, true)
        end

        unit.zuusPassiveStackCount = 0
    end
end


function refreshZuusBuff(keys,flag)
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    local modifierName = "modifier_zuus_cast_buff"
    
    local stackCount = caster.zuusPassiveStackCount
    local ability_speed_up_percent = ability:GetSpecialValueFor("ability_speed_up_percent") * stackCount
    local damage_up_percent = ability:GetSpecialValueFor("damage_up_percent") * stackCount
    

    setPlayerPower(playerID, "talent_ability_speed_percent_final", flag, ability_speed_up_percent)
    setPlayerPower(playerID, "talent_damage_d_percent_final", flag, damage_up_percent)
    setPlayerPower(playerID, "talent_damage_c_percent_final", flag, damage_up_percent)
    setPlayerPower(playerID, "talent_damage_b_percent_final", flag, damage_up_percent)
    setPlayerPower(playerID, "talent_damage_a_percent_final", flag, damage_up_percent)

end