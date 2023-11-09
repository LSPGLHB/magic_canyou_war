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
    --local item_speed = ability:GetSpecialValueFor("item_speed")

    --setPlayerPower(playerID, "player_speed", flag, item_speed)

    --setPlayerBuffByNameAndBValue(keys,"speed",GameRules.playerBaseSpeed)

end

function createSkyEye(keys)
    print("onMake")
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
    local modifierName = "player_"..buffName
    local abilityName = "ability_"..buffName.."_control"
    local modifierNameBuff = "modifier_"..buffName.."_buff"  
    local modifierNameDebuff = "modifier_"..buffName.."_debuff"
    local modifierNameFlag =  PlayerPower[playerID]["player_"..buffName.."_flag"]
    local modifierStackCount = getFinalValueOperation(playerID,baseValue,buffName,nil,"buffStack")-- getPlayerPowerValueByName(hero, modifierName, baseValue)
    local modifierNameAdd
    local modifierNameRemove
    print("modifierNameCount=",modifierStackCount)
    --removePlayerBuffByAbilityAndModifier(unit, abilityName, modifierNameBuff,modifierNameDebuff)
    if ( modifierStackCount > 0 and modifierNameFlag == 1 or modifierStackCount < 0 ) then --增幅且没被禁止，或减幅
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