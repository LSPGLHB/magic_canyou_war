require('player_power')

function modifier_item_magic_gem_on_created(keys)
    print("onCreated")
    refreshItemBuff(keys,true)
end

function modifier_item_magic_gem_on_destroy(keys)
    print("onDestroy")
    refreshItemBuff(keys,false)
end

function refreshItemBuff(keys,flag)
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    local item_mana_regen = ability:GetSpecialValueFor("item_mana_regen")

    setPlayerPower(playerID, "player_mana_regen", flag, item_mana_regen)

    setPlayerBuffByNameAndBValue(keys,"mana_regen",GameRules.playerBaseManaRegen)

end