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



function modifier_battlefield_speed_buff_on_created(keys)
    print("onCreated")
    refreshSpeedBuff(keys,true)
end

function modifier_battlefield_speed_buff_on_destroy(keys)
    print("onDestroy")
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    local hero = PlayerResource:GetSelectedHeroEntity(playerID)
    refreshSpeedBuff(keys,false)
    local abilityName = "battlefield_speed_buff_datadriven"
    removePlayerBuffByAbilityAndModifier(hero, abilityName, "nil", "nil")
end

function refreshSpeedBuff(keys,flag)
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    local speed_init_val = ability:GetSpecialValueFor("speed_init_val")
    setPlayerPower(playerID, "battlefield_speed", flag, speed_init_val)
    setBattlefieldBuffByNameAndBValue(keys,"speed",GameRules.playerBaseSpeed)
end




function modifier_battlefield_mana_regen_buff_on_created(keys)
    print("onCreated")
    refreshManaRegenBuff(keys,true)
end

function modifier_battlefield_mana_regen_buff_on_destroy(keys)
    print("onDestroy")
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    local hero = PlayerResource:GetSelectedHeroEntity(playerID)
    refreshManaRegenBuff(keys,false)
    local abilityName = "battlefield_mana_regen_buff_datadriven"
    removePlayerBuffByAbilityAndModifier(hero, abilityName, "nil", "nil")
end

function refreshManaRegenBuff(keys,flag)
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    local mana_regen_init_val = ability:GetSpecialValueFor("mana_regen_init_val")
    setPlayerPower(playerID, "battlefield_mana_regen", flag, mana_regen_init_val)
    setBattlefieldBuffByNameAndBValue(keys,"mana_regen",GameRules.playerBaseManaRegen)
end








