require('player_power')

function modifier_battlefield_vision_buff_on_created(keys)
    print("onCreated")
    refreshVisionBuff(keys,true)
end

function modifier_battlefield_vision_buff_on_destroy(keys)
    print("onDestroy")
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    local hero = PlayerResource:GetSelectedHeroEntity(playerID)
    refreshVisionBuff(keys,false)
    local abilityName = "battlefield_vision_buff_datadriven"
    removePlayerBuffByAbilityAndModifier(hero, abilityName, "nil", "nil")
end


function refreshVisionBuff(keys,flag)
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    local vision_init_val = ability:GetSpecialValueFor("vision_init_val")
    setPlayerPower(playerID, "battlefield_vision", flag, vision_init_val)
    setBattlefieldBuffByNameAndBValue(keys,"vision",GameRules.playerBaseVision)
end














function initSpeed(keys)
    print("onCreated_player_temp_buff_speed")
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()

    local buffName = "speed"  
    local baseValue = caster:GetIdealSpeed()
    setPlayerDurationBuffByAbilityAndModifier(keys, buffName, baseValue)
end

function initHealth(keys)
    print("onCreated_player_temp_buff_health")
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()

    local buffName = "health"  
    local baseValue = caster:GetHealth()
    setPlayerDurationBuffByAbilityAndModifier(keys, buffName, baseValue)
end

function initMana(keys)
    print("onCreated_player_temp_buff_mana")
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()

    local buffName = "mana"  
    local baseValue = caster:GetMana()
    setPlayerDurationBuffByAbilityAndModifier(keys, buffName, baseValue)
end

function initManaRegen(keys)
    print("onCreated_player_temp_buff_mana_regen")
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()

    local buffName = "mana_regen"  
    local baseValue = caster:GetManaRegen()
    setPlayerDurationBuffByAbilityAndModifier(keys, buffName, baseValue)
end