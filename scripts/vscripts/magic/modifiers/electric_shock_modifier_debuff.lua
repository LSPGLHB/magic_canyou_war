electric_shock_datadriven_modifier_debuff = ({})
--[[
function electric_shock_datadriven_modifier_debuff:OnDestroy()
    local caster = self:GetCaster()
    local playerID = caster:GetPlayerID()
    -- Swap main ability
    local ability_a_name	= keys.ability_a_name
    local ability_b_name	= keys.ability_b_name
    caster:SwapAbilities( ability_a_name, ability_b_name, true, false )

    local shoot_a = PlayerPower[playerID]["electric_shock_a"]

    if shoot_a.launchElectricShock == 0 then
        shootSoundAndParticle(shoot_a, 'miss')
        shootKill(shoot_a)
    end
end]]

modifier_electric_shock_stun = ({})

function modifier_electric_shock_stun:IsDebuff()
    return ture
end

function modifier_electric_shock_stun:GetEffectName()
	return "particles/econ/items/earthshaker/earthshaker_arcana/earthshaker_arcana_stunned_symbol.vpcf"
end

function modifier_electric_shock_stun:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_electric_shock_stun:CheckState()
	local state = {
        [MODIFIER_STATE_STUNNED] = true,
        --[MODIFIER_STATE_ROOTED] = true,
        --[MODIFIER_STATE_MUTED] = true,
        --[MODIFIER_STATE_NIGHTMARED] = true
	}
	return state
end

function modifier_electric_shock_stun:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION
	}
	return funcs
end

function modifier_electric_shock_stun:GetOverrideAnimation(keys)
    return ACT_DOTA_DISABLED
end

