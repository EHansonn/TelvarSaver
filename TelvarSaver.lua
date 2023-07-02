TVS = {}

TVS.name = "Telvar Saver"
TVS.version = "1.4"
TVS.author = "Ehansonn"



TVS.SavedVariablesName = "TVSVars"
TVS.SVVersion = "1.4"
TVS.BackupCamp = "Blackreach"

TVS.CAMPAIGNIDS = {
    ["Ravenswatch"] = 103,
    ["Greyhost"] = 102,
    ["Blackreach"] = 101,
    ["NOCP"] = 96,
    ["CP"] = 95,
    ["Legion Zero"] = 116, -- nocp ic
    ["Dragonfire"] = 119, -- cp ic
    ["Quagmire"] = 111,
    ["Fields of regret"] = 112,
    ["Ashpit"] = 106,
    ["Evergloam"] = 105
}

TVS.alliances = {
    ['AD'] = 1,
    ['EP'] = 2,
    ['DC'] = 3
}

TVS.defaults = {
    AutoLootGold = true,
    AutoLootTelvar = true,
    AutoLootKeyFrags = true,
    notifications = true,
    dragable = true,
    locationx = 275,
    locationy = 150,
    BankScene = true,
    AutoDepoTelvar = true,
    AutoWithdrawTelvar = false,
    DesiredTelvarAmount = 0,
    ICCamp = "NOCP",
    CyroCamp = "Ravenswatch",
    AutoQueueOut = true,
    TelvarCap = 50000,
    GroupQueue = true,

}

TVS.SV = {}

function TVS.onLoad(eventCode, addonName)
    EVENT_MANAGER:UnregisterForEvent(TVS.name, EVENT_ADD_ON_LOADED)
    TVS.SV = ZO_SavedVars:NewAccountWide(TVS.SavedVariablesName, TVS.SVVersion, nil, TVS.defaults)

    -- Creating LAM2 Settings
    TVS.CreateSettingsMenu()


    -- Creating auto queue listener
    EVENT_MANAGER:RegisterForEvent(TVS.name,EVENT_CURRENCY_UPDATE, TVS.AutoQueue)

    -- Bank Scene
    EVENT_MANAGER:RegisterForEvent(TVS.name, EVENT_OPEN_BANK,TVS.DepositTelvar)
    EVENT_MANAGER:RegisterForEvent(TVS.name, EVENT_CLOSE_BANK,TVS.CloseBank)
    EVENT_MANAGER:RegisterForEvent(TVS.name, EVENT_BANKED_CURRENCY_UPDATE,TVS.UpdateText)
    EVENT_MANAGER:RegisterForEvent(TVS.name, EVENT_TELVAR_STONE_UPDATE,TVS.UpdateText)
    --EVENT_MANAGER:RegisterForEvent(TVS.name, EVENT_CURRENCY_UPDATE,TVS.UpdateText)

    -- Creating keybinds
    ZO_CreateStringId("SI_BINDING_NAME_QUEUETVSCAMP", "Queue into your selected campaign")
    SLASH_COMMANDS["/tvs"] = TVS.queueCamp
    --SLASH_COMMANDS["/tvsdb"] = TVS.DebugStuff

    -- Update Bank Scene UI
    TVS.UpdateAnchors()

    -- Auto loot key frags
    EVENT_MANAGER:RegisterForEvent(TVS.name, EVENT_LOOT_UPDATED,TVS.OnLootUpdated)

end
-- Checking if we looted a key fragment
-- Thanks to smarter auto loot for this
function TVS.OnLootUpdated()
    if (IsInImperialCity() == false) then return end
    if (TVS.SV.AutoLootGold == true) then LootMoney() end
    if (TVS.SV.AutoLootTelvar == true) then LootCurrency(CURT_TELVAR_STONES) end

    if (TVS.SV.AutoLootKeyFrags == false) then return end

    local num = GetNumLootItems()
    --d("Loot items number : "..num)
    for i = 1, num, 1 do
        local lootId, name, icon, quantity, quality, value, isQuest, isStolen, lootType = GetLootItemInfo(i)
        local link = GetLootItemLink(lootId)
        local itemType = GetItemLinkItemType(link)

        --d("link: " .. link)
        --d("itemType: " .. itemType)
        --d("lootType: " .. lootType)
        --d("itemId: " .. GetItemLinkItemId(link))

        -- Keyfrag id 64487
        if (GetItemLinkItemId(link) == 64487) then
            TVS.LootItem(link,lootId,quantity)
        end
    end
end
-- Looting the key frag
function TVS.LootItem(link, lootId, quantity)
    LootItemById(lootId)
    --d("Looted ".. tostring(quantity) .. " ".. link)
end



function TVS.CloseBank()
    --TVSView:SetAlpha(0)
    TVSView:SetHidden(true)
end

--  Bank scene to help you manage your telvar. opens menu and auto depos or withdraws if enabled
function TVS.DepositTelvar()
    if (IsInImperialCity() == false) then
        TVS.HideUi()
        return
    end
    --TVSView:SetAlpha(1)
    if (TVS.SV.BankScene == true) then
        TVS.UpdateText()
        TVSView:SetHidden(false)
    end

    local currentTelvarOnChar = GetCarriedCurrencyAmount(CURT_TELVAR_STONES)
    local currentTelvarStonesInBank = GetBankedCurrencyAmount(CURT_TELVAR_STONES)

    if (currentTelvarOnChar > TVS.SV.DesiredTelvarAmount) and (TVS.SV.AutoDepoTelvar == true)then
        local amount = currentTelvarOnChar - TVS.SV.DesiredTelvarAmount
        DepositCurrencyIntoBank(CURT_TELVAR_STONES, amount)
        TVS.UpdateText()
        if (TVS.SV.notifications == true) then d("|c8080ffTelvar Saver|r deposited " .. "|c8080ff" .. tostring(amount).. "|r " .. " into your bank to reach " .. tostring(TVS.SV.DesiredTelvarAmount)) end

        return
    end

    if (currentTelvarOnChar < TVS.SV.DesiredTelvarAmount) and (TVS.SV.AutoWithdrawTelvar == true) then
        local amount = TVS.SV.DesiredTelvarAmount - currentTelvarOnChar
        if (currentTelvarStonesInBank < amount)   then  if ((TVS.SV.notifications== true)) then d("Auto withdraw failed") end return end
        WithdrawCurrencyFromBank(CURT_TELVAR_STONES, amount )
        TVS.UpdateText()
        if (TVS.SV.notifications == true) then  d("|c8080ffTelvar Saver|r attempted to withdraw ".. "|c8080ff" .. tostring(amount).. "|r " .. " from your bank to reach " .. tostring(TVS.SV.DesiredTelvarAmount) ) end

        return
    end

end

-- Buttons in bank scene, withdraws or depos when clicked
function TVS.TelvarButton(value)
    local currentTelvarOnChar = GetCarriedCurrencyAmount(CURT_TELVAR_STONES)
    local currentTelvarStonesInBank = GetBankedCurrencyAmount(CURT_TELVAR_STONES)
    if (currentTelvarOnChar > value) then
        local amount = currentTelvarOnChar - value

        DepositCurrencyIntoBank(CURT_TELVAR_STONES, amount)
        TVS.UpdateText()
        if (TVS.SV.notifications == true) then   d("|c8080ffTelvar Saver|r deposited ".. "|c8080ff" .. tostring(amount).. "|r " .. " into your bank to reach " .. tostring(value)) end

        return
    end

    if (currentTelvarOnChar < value) then
        local amount = value - currentTelvarOnChar
        if (currentTelvarStonesInBank < amount) then d("Not enough telvar to withdraw") return end
        WithdrawCurrencyFromBank(CURT_TELVAR_STONES, amount)
        TVS.UpdateText()
        if (TVS.SV.notifications == true) then   d("|c8080ffTelvar Saver|r attempted to withdraw " .. "|c8080ff" .. tostring(amount).. "|r " .. " from your bank to reach " .. tostring(value) ) end

        return
    end
end


-- For when you gain telvar and exceed your cap
function TVS.AutoQueue(eventCode, currencyType, currencyLocation, newAmount, oldAmount, reason, reasonSupplementaryInfo)
    if not IsInImperialCity() then return end
    if currencyType ~= CURT_TELVAR_STONES then return end
    if currencyLocation ~= CURRENCY_LOCATION_CHARACTER then return end
    if reason ~= CURRENCY_CHANGE_REASON_PVP_KILL_TRANSFER and reason ~= CURRENCY_CHANGE_REASON_LOOT then return end
    if (TVS.SV.AutoQueueOut == false) then return end

    local currentTelvarOnChar = GetCarriedCurrencyAmount(CURT_TELVAR_STONES)
    if (currentTelvarOnChar >= TVS.SV.TelvarCap) then
        local queueCyro = TVS.CAMPAIGNIDS[TVS.SV.CyroCamp]
        -- d(GetCampaignQueueState(queueCyro))
        if (GetCampaignQueueState(queueCyro) ~= 3) then return else
            if (TVS.SV.notifications == true) then   d("MAX TELVAR REACHED, queued for campaign") end

            local groupQueue = false
            if (IsUnitGrouped('player') == true) and (IsUnitGroupLeader("player") == true) then
                groupQueue = TVS.SV.GroupQueue
            end
            QueueForCampaign(queueCyro,groupQueue)
        end
    end
end

-- For the keybind button press
function TVS.queueCamp()

    local queueIC = TVS.CAMPAIGNIDS[TVS.SV.ICCamp]
    local queueCyro = TVS.CAMPAIGNIDS[TVS.SV.CyroCamp]

    -- Backup incase GH or BR has a queue -- Hopefully this works lol?
    if (GetCampaignQueuePosition(queueCyro) > 0) then
        queueCyro = TVS.CAMPAIGNIDS["Ravenswatch"]
    end

    -- GroupQueue Stuff
    local groupQueue = false
    if (IsUnitGrouped('player') == true) and (IsUnitGroupLeader("player") == true) then
        groupQueue = TVS.SV.GroupQueue
    end


    if (IsInImperialCity() == true)  then
        if (GetCampaignQueueState(queueCyro) ~= 3)  then return else
            QueueForCampaign(queueCyro,groupQueue)
        end
    else if (IsInCyrodiil() == true)  or (IsInAvAZone() == false) then
        if (GetCampaignQueueState(queueIC) ~= 3)  then return else
            QueueForCampaign(queueIC,groupQueue)
        end
    end
    end
end




function TVS.DebugStuff()
    d("|c8080ff10k|r")
end
-- Entry Point
EVENT_MANAGER:RegisterForEvent(TVS.name,EVENT_ADD_ON_LOADED,TVS.onLoad)
