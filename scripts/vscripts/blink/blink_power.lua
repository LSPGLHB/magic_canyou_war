require('game_init')
require('shoot_init')
require('player_power')
blink_power = ({})
blink_power_passive = ({})
blink_power_buff = ({})
LinkLuaModifier("blink_power_passive", "blink/blink_power.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("blink_power_buff", "blink/blink_power.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)

function blink_power:GetCastRange(v,t)
    local range = getRangeByName(self,'blink')
    return range
end

function blink_power:GetIntrinsicModifierName()
	return "blink_power_passive"
end

function blink_power:OnSpellStart()
    local caster = self:GetCaster()
    local ability = self

    local duration = ability:GetSpecialValueFor("duration")
    local search_radius = ability:GetSpecialValueFor("search_radius")

    local fromParticle = "particles/shanxian_qianghua_xiaoshi.vpcf"
    local toParticle = "particles/shanxian_qianghua_chuxian.vpcf"
    local posParticle = "particles/shanxian_qianghua_beidong_dimian.vpcf"
 
    EmitSoundOn("scene_voice_blink_power_cast", caster)

    local newPosition = blinkOperation(caster, ability, fromParticle, toParticle, nil)


    local particlePos = ParticleManager:CreateParticle(posParticle, PATTACH_WORLDORIGIN, caster)
    ParticleManager:SetParticleControl(particlePos, 0, newPosition)
    ParticleManager:SetParticleControl(particlePos, 1, Vector(search_radius,0,0))
    ParticleManager:SetParticleControl(particlePos, 2, Vector(duration,0,0))
    
    


    local playerIDArray = {}
    local casterTeam = caster:GetTeam()
    local buffName = "blink_power_buff"
    local interval = 0.02
    local overFlag = false
    Timers:CreateTimer(duration,function()
        overFlag = true
    end)

    
    Timers:CreateTimer(function()
        if overFlag then
            ParticleManager:DestroyParticle(particlePos, true)  
            for _, playerID in pairs(playerIDArray) do
                local hHero = PlayerResource:GetSelectedHeroEntity(playerID)
                hHero:RemoveModifierByName(buffName)
            end
            return nil
        end
        
        local tempPlayerArray = {}
        local aroundUnits = FindUnitsInRadius(casterTeam, 
                                            newPosition,
                                            nil,
                                            search_radius,
                                            DOTA_UNIT_TARGET_TEAM_BOTH,
                                            DOTA_UNIT_TARGET_ALL,
                                            0,
                                            0,
                                            false)
        for _, unit in pairs(aroundUnits) do
            if unit:IsHero() and casterTeam == unit:GetTeam() then
                local heroID = unit:GetPlayerID()
                table.insert(tempPlayerArray, heroID)
                if not unit:HasModifier(buffName) then
                    unit:AddNewModifier(caster, ability, buffName, {Duration = -1})
                end
            end
        end

        for _, oldID in pairs(playerIDArray) do
            local clearFlag = true
            for _, newID in pairs(tempPlayerArray) do
                if oldID == newID then
                    clearFlag = false
                end
            end
            if clearFlag then
                local hHero = PlayerResource:GetSelectedHeroEntity(oldID)
                hHero:RemoveModifierByName(buffName)
            end
        end
        playerIDArray = tempPlayerArray
        return interval
    end)

    caster.shootOver = -1
end

function blink_power_buff:IsBuff()
	return true
end

function blink_power_buff:GetEffectName()
	return "particles/shanxian_qianghua_beidong_renwu.vpcf"
end

function blink_power_buff:GetEffectAttachType()
	return PATTACH_POINT_FOLLOW
end

function blink_power_buff:OnCreated()
    if IsServer() then
        local keys = {}
        keys.caster = self:GetParent()
        keys.ability = self:GetAbility()
        refreshBlinkPowerBuffBuff(keys,true)
    end
end

function blink_power_buff:OnDestroy()
    if IsServer() then
        local keys = {}
        keys.caster = self:GetParent()
        keys.ability = self:GetAbility()
        refreshBlinkPowerBuffBuff(keys,false)
    end
end

function refreshBlinkPowerBuffBuff(keys,flag)
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    local buff_ability_speed_percent = ability:GetSpecialValueFor("buff_ability_speed_percent")
    local buff_damage = ability:GetSpecialValueFor("buff_damage")

    setPlayerPower(playerID, "talent_damage_d", flag, buff_damage)
    setPlayerPower(playerID, "talent_damage_c", flag, buff_damage)
    setPlayerPower(playerID, "talent_damage_b", flag, buff_damage)
    setPlayerPower(playerID, "talent_damage_a", flag, buff_damage)
    setPlayerPower(playerID, "talent_ability_speed_percent_final", flag, buff_ability_speed_percent)

    setPlayerBuffByNameAndBValue(keys,"speed",GameRules.playerBaseSpeed)
end

function blink_power_passive:IsHidden()
    return true
end

function blink_power_passive:OnCreated()
    if IsServer() then
        local keys = {}
        keys.caster = self:GetParent()
        keys.ability = self:GetAbility()
        refreshBlinkPowerBuff(keys,true)
    end
end

function blink_power_passive:OnDestroy()
    if IsServer() then
        local keys = {}
        keys.caster = self:GetParent()
        keys.ability = self:GetAbility()
        refreshBlinkPowerBuff(keys,false)
    end
end

function refreshBlinkPowerBuff(keys,flag)
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    local damage = ability:GetSpecialValueFor("damage")
    local range = ability:GetSpecialValueFor("range")

    setPlayerPower(playerID, "contract_damage_d", flag, damage)
    setPlayerPower(playerID, "contract_damage_c", flag, damage)
    setPlayerPower(playerID, "contract_damage_b", flag, damage)
    setPlayerPower(playerID, "contract_damage_a", flag, damage)
    setPlayerPower(playerID, "contract_range", flag, range)


    setPlayerSimpleBuff(keys,"range")

end