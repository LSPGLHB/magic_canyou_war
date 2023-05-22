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
    --local unit = keys.unit 
    local position = caster:GetAbsOrigin()
    local duration = ability:GetSpecialValueFor("duration")
    local visionBuff = keys.buffName
    local noBarBuff = keys.noBarBuff
    local timeOver= 0
    --local sky_eye_unit = CreateUnitByName("sky_eye", position, true, nil, nil, caster:GetTeam())--DOTA_TEAM_BADGUYS)--

    ability:ApplyDataDrivenModifier(caster, caster, visionBuff, {Duration = duration})
    --ability:ApplyDataDrivenModifier(sky_eye_unit, sky_eye_unit, noBarBuff, {Duration = duration})
    Timers:CreateTimer(0,function ()
        if timeOver == 1 then

            return nil
        end
        CreateUnitByName("sky_eye", caster:GetAbsOrigin(), true, nil, nil, caster:GetTeam())
        return 0.1
    end)

    Timers:CreateTimer(duration,function ()
        timeOver = 1
    end)
end