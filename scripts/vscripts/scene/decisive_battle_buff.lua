require('player_power')
require('game_init')
function modifier_decisive_battle_buff_on_created(keys)
    print("onCreated")
    refreshDecisiveBattleBuff(keys,true)
end

function modifier_decisive_battle_buff_on_destroy(keys)
    print("onDestroy")
    refreshDecisiveBattleBuff(keys,false)
end

function refreshDecisiveBattleBuff(keys,flag)
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    local mana_regen = ability:GetSpecialValueFor("mana_regen")
    local cooldown = ability:GetSpecialValueFor("cooldown")
    
    setPlayerPower(playerID, "temp_mana_regen", flag, mana_regen)
    setPlayerBuffByNameAndBValue(keys,"mana_regen",GameRules.playerBaseManaRegen)
    setPlayerPower(playerID, "temp_cooldown", flag, cooldown)
    setPlayerBuffByNameAndBValue(keys,"cooldown",0)
end
