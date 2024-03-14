require('player_power')

function modifier_item_dragon_squama_on_created(keys)
    print("onCreated")
    refreshItemBuff(keys,true)
end

function modifier_item_dragon_squama_on_destroy(keys)
    print("onDestroy")
    refreshItemBuff(keys,false)
end

function refreshItemBuff(keys,flag)
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    local item_defense = ability:GetSpecialValueFor("item_defense")

    setPlayerPower(playerID, "player_defense", flag, item_defense)

   setPlayerBuffByNameAndBValue(keys,"defense",GameRules.playerBaseDefense)

end