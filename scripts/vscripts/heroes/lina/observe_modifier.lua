modifier_observe_buff = ({})

function modifier_observe_buff:DeclareFunctions()
	local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE
	}
	return funcs
end

function modifier_observe_buff:OnTakeDamage(keys)
    if IsServer() and keys.attacker == self:GetParent() then
        local ability = self:GetAbility()
        local cooldown_reduce = ability:GetSpecialValueFor("cooldown_reduce")
        local cooldownTimeRemaining = ability:GetCooldownTimeRemaining()
        cooldownTimeRemaining = cooldownTimeRemaining - cooldown_reduce
        ability:EndCooldown()
        ability:StartCooldown(cooldownTimeRemaining)
    end
end

