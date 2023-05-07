require('player_power')

function modifier_item_dragon_heart_on_created(keys)
    print("onCreated")
    refreshItemBuff(keys,true)
end

function modifier_item_dragon_heart_on_destroy(keys)
    print("onDestroy")
    refreshItemBuff(keys,false)
end


function refreshItemBuff(keys,flag)
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    local item_health = ability:GetSpecialValueFor("item_health")

    setPlayerPower(playerID, "player_health", flag, item_health)

    setPlayerBuffByNameAndBValue(keys,"health",GameRules.playerBaseHealth)
end
