require('player_power')

function modifier_item_sky_eye_on_created(keys)
    print("onCreated")
    refreshItemBuff(keys,true)
end

function modifier_item_sky_eye_on_destroy(keys)
    print("onDestroy")
    refreshItemBuff(keys,false)
end

function refreshItemBuff(keys,flag)
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()

    local item_vision = ability:GetSpecialValueFor("item_vision")
    local item_health = ability:GetSpecialValueFor("item_health")
    local item_cooldown_percent_final = ability:GetSpecialValueFor("item_cooldown_percent_final")
    local item_mana_regen = ability:GetSpecialValueFor("item_mana_regen")
    
    setPlayerPower(playerID, "player_vision", flag, item_vision)
    setPlayerPower(playerID, "player_health", flag, item_health)
    setPlayerPower(playerID, "player_cooldown_percent_final", flag, item_cooldown_percent_final)
    setPlayerPower(playerID, "player_mana_regen", flag, item_mana_regen)
    
    setPlayerBuffByNameAndBValue(keys,"vision",GameRules.playerBaseVision)
    setPlayerBuffByNameAndBValue(keys,"health",GameRules.playerBaseHealth)
    setPlayerSimpleBuff(keys,"cooldown_percent_final")
    setPlayerBuffByNameAndBValue(keys,"mana_regen",GameRules.playerBaseManaRegen)

end

function createSkyEye(keys)
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    --local unit = keys.unit 
    local position = caster:GetAbsOrigin()
    local duration = ability:GetSpecialValueFor("duration")
    local visionBuff = keys.buffName
    local noBarBuff = keys.noBarBuff
    local timeOver= 0
    local sky_eye_unit = CreateUnitByName("sky_eye", position, true, nil, nil, caster:GetTeam())--DOTA_TEAM_BADGUYS)--
    setClassBuff(keys, 'vision', GameRules.playerBaseVision, sky_eye_unit)
    ability:ApplyDataDrivenModifier(caster, caster, visionBuff, {Duration = duration})
    ability:ApplyDataDrivenModifier(sky_eye_unit, sky_eye_unit, noBarBuff, {Duration = duration})

    Timers:CreateTimer(duration,function ()
        if sky_eye_unit ~= nil then
            sky_eye_unit:ForceKill(true)
            sky_eye_unit:AddNoDraw()
            --print("kill-shoot")
        end
        timeOver = 1
    end)

    Timers:CreateTimer(0,function ()
        if timeOver == 1 then    
            return nil
        end
        sky_eye_unit:SetAbsOrigin(caster:GetAbsOrigin())
        return 0.1
    end)

    
end

function setClassBuff(keys,buffName,baseValue,unit)
    local hero = keys.caster
    local playerID = hero:GetPlayerID()

    local abilityName = "ability_"..buffName.."_control"
    local modifierNameBuff = "modifier_"..buffName.."_buff"  
    local modifierNameDebuff = "modifier_"..buffName.."_debuff"
    local modifierStackCount = getFinalValueOperation(playerID,baseValue,buffName,nil,nil)-- getPlayerPowerValueByName(hero, modifierName, baseValue)
    local modifierNameAdd
    local modifierNameRemove
    print("modifierNameCount=",modifierStackCount)
    --removePlayerBuffByAbilityAndModifier(unit, abilityName, modifierNameBuff,modifierNameDebuff)
    if modifierStackCount ~= 0 then
        if (modifierStackCount > 0) then   
            modifierNameAdd = modifierNameBuff
            modifierNameRemove = modifierNameDebuff
        else
            modifierNameAdd = modifierNameDebuff
            modifierNameRemove = modifierNameBuff
            modifierStackCount = modifierStackCount * -1
        end
        --print("modifierNameAdd",modifierNameAdd)
        unit:AddAbility(abilityName):SetLevel(1)
        unit:RemoveModifierByName(modifierNameRemove)
        unit:SetModifierStackCount(modifierNameAdd, unit, modifierStackCount)
        unit:RemoveAbility(abilityName)

        --卡bug过关(OnDestory层数减少时，需要再执行一次，否则不能正常运作)
        unit:AddAbility(abilityName):SetLevel(1)
        unit:RemoveModifierByName(modifierNameRemove)
        unit:SetModifierStackCount(modifierNameAdd, unit, modifierStackCount)
        unit:RemoveAbility(abilityName)
    end
end