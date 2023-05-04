require('player_power')

function modifier_item_dragon_eye_on_created(keys)
    print("onCreated")
    refreshItemBuff(keys,true)
end

function modifier_item_dragon_eye_on_destroy(keys)
    print("onDestroy")
    refreshItemBuff(keys,false)
end

function refreshItemBuff(keys,flag)
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    local item_vision = ability:GetSpecialValueFor("item_vision")

    setPlayerPower(playerID, "player_vision", flag, item_vision)

    setPlayerBuffByNameAndBValue(caster,"vision",GameRules.playerBaseVision)

end