eventHandler.GreatHouseQuestException = function(pid)

    local GHQuestPrefixes = { "ht", "hr", "hh" }

    for i = 0, tes3mp.GetJournalChangesSize(pid) - 1 do

        local quest = tes3mp.GetJournalItemQuest(pid, i)
        local questPrefix = string.sub(quest, 1, 2)

        if tableHelper.containsValue(GHQuestPrefixes, questPrefix) then
            return true
        end
    end
end
--471 to 484 is a modification of David's code from here:
--(https://forum.openmw.org/viewtopic.php?f=45&t=5035&start=10)
--Purpose: To Tell TES3MP to keep an eye out for any quest coming from one of the great houses.
eventHandler.OnPlayerJournal = function(pid)
    if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
        local eventStatus = customEventHooks.triggerValidators("OnPlayerJournal", {pid})
        if eventStatus.validDefaultHandler then
            if eventHandler.GreatHouseQuestException(pid) then
			Players[pid]:SaveJournal()
			--If the Journal Change is instigated by a Great House Quest then it'll save to the Player journal.
            else
                WorldInstance:SaveJournal(pid)
				
                -- Send this PlayerJournal packet to other players (sendToOthersPlayers is true),
                -- but skip sending it to the player we got it from (skipAttachedPlayer is true)
                tes3mp.SendJournalChanges(pid, true, true)
            end
        end
        customEventHooks.triggerHandlers("OnPlayerJournal", eventStatus, {pid})
    end
end
