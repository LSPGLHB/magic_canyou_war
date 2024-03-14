require('shoot_init')
modifier_omniknight_passive = ({})
modifier_omniknight_buff = ({})
LinkLuaModifier("modifier_omniknight_passive", "heroes/omniknight/supply_modifier.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_omniknight_buff", "heroes/omniknight/supply_modifier.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)

function modifier_omniknight_passive:IsHidden()
    return true
end
--搜索自家碰撞减CD
function modifier_omniknight_passive:OnCreated()
    if IsServer() then
        local unit = self:GetParent()
        local ability = self:GetAbility()
        local aoe_radius = ability:GetSpecialValueFor("aoe_radius")
        local aoeTargetBuff = "modifier_omniknight_buff"
        unit.haloPassiveInterval = 1
        local casterTeam = unit:GetTeam()
        
        Timers:CreateTimer(function()
            if unit.haloPassiveInterval == 0 then
                return nil
            end
            unit.tempHitUnits = {}
            local aroundUnits = FindUnitsInRadius(casterTeam, 
                                        unit:GetAbsOrigin(),
										nil,
										aoe_radius,
										DOTA_UNIT_TARGET_TEAM_BOTH,
										DOTA_UNIT_TARGET_ALL,
										0,
										0,
										false)
            for k,value in pairs(aroundUnits) do
                --local unitTeam = value:GetTeam()
                --local unitEnergy = unit.energy_point
                --local label = value:GetUnitLabel()
                if value:GetTeam() == casterTeam and value:IsHero() then
                    local newFlag = checkHitUnitToMark(unit, value)--用于技能结束时清理debuff	
                    if newFlag then  --新加入的加上buff	
                        value:AddNewModifier( unit, ability, aoeTargetBuff, {Duration = -1} )
                        value.omniknightHero = unit
                        print("unitID:"..unit:GetPlayerID())
                    end
                    table.insert(unit.tempHitUnits, value)
                end
            end
            refreshBuffByArray(unit,aoeTargetBuff)
            return 0.1
        end)
    end
end

function modifier_omniknight_passive:OnDestroy()
    if IsServer() then
        local unit = self:GetParent()
        local ability = self:GetAbility()
        unit.haloPassiveInterval = 0 
    end
end



function modifier_omniknight_buff:IsBuff()
	return true
end

function modifier_omniknight_buff:OnCreated()
    if IsServer() then
        local unit = self:GetParent()
        unit.omniknightBuffArray = {}
    end
end

function modifier_omniknight_buff:OnDestroy()
    if IsServer() then
        local unit = self:GetParent()
        unit.omniknightBuffArray = nil
    end
end
function modifier_omniknight_buff:DeclareFunctions()
	local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE
	}
	return funcs
end

function modifier_omniknight_buff:OnTakeDamage(keys)
    --受伤的是buff主人
    if IsServer() and keys.unit == self:GetParent() then
        --local caster = self:GetCaster()
        local ability = self:GetAbility()
        local unit = self:GetParent()
        local damage = keys.damage
        local shoot = keys.attacker

        local isContain = checkContainsArrayValue(unit.omniknightBuffArray, shoot)
        if not isContain then   
            table.insert(unit.omniknightBuffArray,shoot)
            local hHero = unit.omniknightHero
            local abilityName = "npc_dota_hero_omniknight_ability"  
            local hitAbility = hHero:FindAbilityByName(abilityName)
            local cooldownReduce = hitAbility:GetSpecialValueFor("cooldown_reduce")
            local particlesName = "particles/huixuege_beidong.vpcf"
            local hitCooldownTimeRemaining = hitAbility:GetCooldownTimeRemaining()
            --print("hitCooldownTimeRemaining")
            --print(hitCooldownTimeRemaining.."-"..cooldownReduce)
            hitCooldownTimeRemaining = hitCooldownTimeRemaining - cooldownReduce
            if hitCooldownTimeRemaining > 0 then
                hitAbility:EndCooldown()
                hitAbility:StartCooldown(hitCooldownTimeRemaining)
            end
            local hitParticleID = ParticleManager:CreateParticle(particlesName, PATTACH_POINT_FOLLOW, hHero)
            ParticleManager:SetParticleControl(hitParticleID, 0, hHero:GetAbsOrigin())
            Timers:CreateTimer(1,function()
                ParticleManager:DestroyParticle(hitParticleID, true)
            end)

        end

    end
    --[[攻击者为buff主人
    if IsServer() and keys.attacker == self:GetParent() then
        print("222222222")
    end]]
end

