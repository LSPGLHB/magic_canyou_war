modifier_vengefulspirit_cast_buff = ({})

function modifier_vengefulspirit_cast_buff:IsBuff()
    return true
end

function modifier_vengefulspirit_cast_buff:OnCreated()
    if IsServer() then
        local unit = self:GetParent()
        local ability = self:GetAbility()
        local cooldown_reduce = ability:GetSpecialValueFor("cooldown_reduce")
        local mana_regen = ability:GetSpecialValueFor("mana_regen")
        local speed_up = ability:GetSpecialValueFor("speed_up")
        local ability_speed_up_percent = ability:GetSpecialValueFor("ability_speed_up_percent")
        local damage_up_percent = ability:GetSpecialValueFor("damage_up_percent")
        local control_up_percent = ability:GetSpecialValueFor("control_up_percent")
        local radius_up_percent = ability:GetSpecialValueFor("radius_up_percent")
        local range_up_percent = ability:GetSpecialValueFor("range_up_percent")
        local energy_up_percent = ability:GetSpecialValueFor("energy_up_percent")
        local power_up_duration = ability:GetSpecialValueFor("power_up_duration")

        local unitTeam = unit:GetTeam()
        local friendlyTeamer = 0
        local enemyTeamer = 0
        for playerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
			if PlayerResource:GetConnectionState(playerID) ~= DOTA_CONNECTION_STATE_UNKNOWN then
				local hHero = PlayerResource:GetSelectedHeroEntity(playerID) 
                if hHero:IsAlive() then 
                    local hHeroTeam = hHero:GetTeam()
                    if unitTeam == hHeroTeam then
                        friendlyTeamer = friendlyTeamer + 1
                    else
                        enemyTeamer = enemyTeamer + 1
                    end
                end
            end
        end

        local stackCount = enemyTeamer - friendlyTeamer
        if stackCount <= 0 then
            stackCount = 1
        end
        if stackCount >= 3 then
            stackCount = 3
        end
        unit.vengefulspiritPassiveStackCount = stackCount
        unit:SetModifierStackCount("modifier_vengefulspirit_cast_buff", unit, stackCount)
        local keys = {}
        keys.caster = self:GetParent()
        keys.ability = self:GetAbility()
        refreshVengefulspiritBuff(keys,true)
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
        --print(vx..","..vy..","..vz)
        local particleID = ParticleManager:CreateParticle("particles/fuchouge.vpcf", PATTACH_ABSORIGIN_FOLLOW, unit)
		ParticleManager:SetParticleControl(particleID, 0, unit:GetAbsOrigin())
        ParticleManager:SetParticleControl(particleID, 2, Vector(vx,vy,vz))
		unit.vengefulspiritPassiveParticlesID = particleID
    end
end

function modifier_vengefulspirit_cast_buff:OnDestroy()
    if IsServer() then
        local unit = self:GetParent()    
        local keys = {}
        keys.caster = self:GetParent()
        keys.ability = self:GetAbility()
        refreshVengefulspiritBuff(keys,false)
        unit.vengefulspiritPassiveStackCount = 0

        ParticleManager:DestroyParticle(unit.vengefulspiritPassiveParticlesID, true)
        unit.vengefulspiritPassiveParticlesID = nil
    end
end

function refreshVengefulspiritBuff(keys,flag)
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    local modifierName = "modifier_zuus_cast_buff"
    
    local stackCount = caster.vengefulspiritPassiveStackCount

    local cooldown_reduce = ability:GetSpecialValueFor("cooldown_reduce") * stackCount
    local mana_regen = ability:GetSpecialValueFor("mana_regen") * stackCount
    local speed_up = ability:GetSpecialValueFor("speed_up") * stackCount
    local ability_speed_up_percent = ability:GetSpecialValueFor("ability_speed_up_percent") * stackCount
    local damage_up_percent = ability:GetSpecialValueFor("damage_up_percent") * stackCount
    local control_up_percent = ability:GetSpecialValueFor("control_up_percent") * stackCount
    local radius_up_percent = ability:GetSpecialValueFor("radius_up_percent") * stackCount
    local range_up_percent = ability:GetSpecialValueFor("range_up_percent") * stackCount
    local energy_up_percent = ability:GetSpecialValueFor("energy_up_percent") * (stackCount -1)
    

    
    --mana_regen
    caster:GiveMana(mana_regen)
    
    setPlayerPower(playerID, "talent_ability_speed_percent_final", flag, ability_speed_up_percent)
    setPlayerPower(playerID, "talent_damage_d_percent_final", flag, damage_up_percent)
    setPlayerPower(playerID, "talent_damage_c_percent_final", flag, damage_up_percent)
    setPlayerPower(playerID, "talent_damage_b_percent_final", flag, damage_up_percent)
    setPlayerPower(playerID, "talent_damage_a_percent_final", flag, damage_up_percent)
    setPlayerPower(playerID, "talent_control_percent_final", flag, control_up_percent)

    setPlayerPower(playerID, "talent_cooldown", flag, cooldown_reduce) --冷却实数不减充能，百分比才减充能
    setPlayerPower(playerID, "talent_speed", flag, speed_up)
    setPlayerPower(playerID, "talent_radius_percent_final", flag, radius_up_percent)
    setPlayerPower(playerID, "talent_range_percent_final", flag, range_up_percent)

    setPlayerBuffByNameAndBValue(keys,"speed",GameRules.playerBaseSpeed)
    setPlayerSimpleBuff(keys,"cooldown")
    setPlayerSimpleBuff(keys,"range_percent_final")
    setPlayerSimpleBuff(keys,"radius_percent_final")
    if stackCount >= 2 then
        setPlayerPower(playerID, "talent_energy_percent_final", flag, energy_up_percent)
    end
    
end

function modifier_vengefulspirit_cast_buff:OnAbilityStart(keys)
    if IsServer() and keys.unit == self:GetParent() then
        local unit = self:GetParent()
        local modifierName = "modifier_vengefulspirit_cast_buff"
        powerUpAbilityCount(unit, modifierName, 1, nil, nil)
    end
end

