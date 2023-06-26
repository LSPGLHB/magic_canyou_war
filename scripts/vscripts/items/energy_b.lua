require('player_power')

function modifier_item_energy_b_on_created(keys)
    print("onCreated")
    refreshItemBuff(keys,true)
end

function modifier_item_energy_b_on_destroy(keys)
    print("onDestroy")
    refreshItemBuff(keys,false)
end

function refreshItemBuff(keys,flag)
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    local item_energy_b_precent_base = ability:GetSpecialValueFor("item_energy_b_precent_base")
    local item_mana_cost_b_precent_base = ability:GetSpecialValueFor("item_mana_cost_b_precent_base")

    setPlayerPower(playerID, "player_energy_b_precent_base", flag, item_energy_b_precent_base)
    setPlayerPower(playerID, "player_mana_cost_b_precent_base", flag, item_mana_cost_b_precent_base)

end