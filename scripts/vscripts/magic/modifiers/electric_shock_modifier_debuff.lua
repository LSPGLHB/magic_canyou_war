modifier_electric_shock_datadriven_buff = ({})

function modifier_electric_shock_datadriven_buff:OnDestroy()
    local caster = self:GetParent()
    local playerID = caster:GetPlayerID()
    -- Swap main ability
    local ability_a_name	= "electric_shock_datadriven"
    local ability_b_name	= "electric_shock_datadriven_stage_b"
    caster:SwapAbilities( ability_a_name, ability_b_name, true, false )

    local shoot_a = caster.electric_shock_a

    if shoot_a.launchElectricShock == 0 then
        shootSoundAndParticle(shoot_a, 'miss')
        shootKill(shoot_a)
    end
end
--[[
function initStage(caster)
    --local caster	= keys.caster
	--local ability	= keys.ability
    local playerID = caster:GetPlayerID()
    -- Swap main ability
    local ability_a_name	= "electric_shock_datadriven"
    local ability_b_name	= "electric_shock_datadriven_stage_b"
    caster:SwapAbilities( ability_a_name, ability_b_name, true, false )
    local shoot_a = caster.electric_shock_a
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
        [MODIFIER_STATE_STUNNED] = true
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

