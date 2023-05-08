require('player_power')

function modifier_item_magic_staff_on_created(keys)
    print("onCreated")
    refreshItemBuff(keys,true)
end

function modifier_item_magic_staff_on_destroy(keys)
    print("onDestroy")
    refreshItemBuff(keys,false)
end

function refreshItemBuff(keys,flag)
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    local item_mana = ability:GetSpecialValueFor("item_mana")

    setPlayerPower(playerID, "player_mana", flag, item_mana)

    setPlayerBuffByNameAndBValue(keys,"mana",GameRules.playerBaseMana)

end