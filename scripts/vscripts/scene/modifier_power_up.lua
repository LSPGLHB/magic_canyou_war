modifier_power_up= class({})
--------------------------------------------------------------------------------

function modifier_power_up:GetCastRange()
    local caster = self.GetCaster()
    local ability = caster:GetAbilityByIndex(3)
    local range = 1500 --ability:GetAbilityCastRange()
    print("modifier_power_up:"..range)
    range = range - 1000
	return range
end