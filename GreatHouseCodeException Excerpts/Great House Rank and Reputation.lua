eventHandler.GreatHouseFactionException = function(pid)

    local GHFactionIDs = { "hlaalu", "redoran", "Telvanni" }

        if tableHelper.containsValue(GHFactionIDs) then
            return true
        end
    end
-- Tells TES3MP to specifically watch for the faction IDs of the Great Houses
eventHandler.OnPlayerFaction = function(pid)
    if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then

        local action = tes3mp.GetFactionChangesAction(pid)
        
        local eventStatus = customEventHooks.triggerValidators("OnPlayerFaction", {pid, action})
        
        if eventStatus.validDefaultHandler then
            if action == enumerations.faction.RANK then
                if eventHandler.GreatHouseFactionException then

                    Players[pid]:SaveFactionRanks()
					--If the faction is one of the Great Houses
					--then it saves the change in rank to the player file.
                else
                    WorldInstance:SaveFactionRanks(pid)
                    -- Send this PlayerFaction packet to other players (sendToOthersPlayers is true),
                    -- but skip sending it to the player we got it from (skipAttachedPlayer is true)
                    tes3mp.SendFactionChanges(pid, true, true)
                end
            elseif action == enumerations.faction.EXPULSION then
                if config.shareFactionExpulsion == true then

                    WorldInstance:SaveFactionExpulsion(pid)
                    -- As above, send this to everyone other than the original sender
                    tes3mp.SendFactionChanges(pid, true, true)
                else
                    Players[pid]:SaveFactionExpulsion()
                end
            elseif action == enumerations.faction.REPUTATION then
                if eventHandler.GreatHouseFactionException == true then
				
					Players[pid]:SaveFactionReputation()
					--Like the faction rank change action, but for reputation.
                else
                    WorldInstance:SaveFactionReputation(pid)

                    -- As above, send this to everyone other than the original sender
                    tes3mp.SendFactionChanges(pid, true, true)
                end
            end
        end
        
        customEventHooks.triggerHandlers("OnPlayerFaction", eventStatus, {pid, action})
    end
end
