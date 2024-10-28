local LAM = LibAddonMenu2
-- Creating LAM2 MENU --
function TVS.CreateSettingsMenu()
    local panelName = "Telvar Saver"
    local panelData = {
        type = "panel",
        name = TVS.name,
        displayName = panelName,
        author = TVS.author,
        version = TVS.version,
        registerForRefresh = true,
        registerForDefaults = true,
    }
    local options = {}

    table.insert(options, {
        type = "description",
        text = "Check your controls for the keybind, its unbound by default",

    })
    table.insert(options,
            {
                type = "checkbox",
                name = "Chat Notifications",
                textType = TEXT_TYPE_NUMERIC_UNSIGNED_INT,
                tooltip = "",
                default = TVS.defaults.notifications,
                getFunc = function() return TVS.SV.notifications end,
                setFunc = function(value)
                    TVS.SV.notifications = value
                end,
            })

    table.insert(options, {
        type = "header",
        name = "Campaign Options",

    })
    local cyroChoices = {'Greyhost','Blackreach','Ravenwatch'}
    if (TVS.SV.midyear == true) then cyroChoices ={'Greyhost','Blackreach','Ravenwatch',"Quagmire","Fields of regret","Ashpit","Evergloam"} end

    table.insert(options,
            {
                type = "dropdown",
                name = "Preferred Cyro Campaign",
                textType = TEXT_TYPE_NUMERIC_UNSIGNED_INT,
                tooltip = "pick ya poison",
                choices = cyroChoices,
                default = TVS.defaults.CyroCamp,
                getFunc = function() return TVS.SV.CyroCamp end,
                setFunc = function(value)
                    TVS.SV.CyroCamp = value
                end,
            })
    local icChoices = {'NOCP','CP',"Last visited"}
    if (TVS.SV.midyear == true) then icChoices = {'NOCP','CP',"Last visited","Dragonfire","Legion Zero"} end

    table.insert(options,
            {
                type = "dropdown",
                name = "Preferred IC Campaign",
                textType = TEXT_TYPE_NUMERIC_UNSIGNED_INT,
                tooltip = "NOCP or CP IC. Last visited will queue you into the campaign you visited last",
                choices = icChoices,
                default = TVS.defaults.ICCamp,
                getFunc = function() return TVS.SV.ICCamp end,
                setFunc = function(value)
                    TVS.SV.ICCamp = value
                end,
            })

    table.insert(options,
            {
                type = "checkbox",
                name = "Use backup campaign",
                textType = TEXT_TYPE_NUMERIC_UNSIGNED_INT,
                tooltip = "If your preferred camp has a queue (ie greyhost during prime time) it will unqueue you and requeue you for the backup",
                default = TVS.defaults.UseBackup,
                getFunc = function() return TVS.SV.UseBackup end,
                setFunc = function(value)
                    TVS.SV.UseBackup = value
                end,
            })

    table.insert(options,
            {
                type = "dropdown",
                name = "Backup Campaign",
                textType = TEXT_TYPE_NUMERIC_UNSIGNED_INT,
                tooltip = "Campaign to use if your preferred cyro campaign has a queue",
                choices = cyroChoices,
                default = "Ravenwatch",
                getFunc = function() return TVS.SV.BackupCamp end,
                setFunc = function(value)
                    TVS.SV.BackupCamp = value
                end,
            })

    table.insert(options,
            {
                type = "checkbox",
                name = "Auto accept queue",
                textType = TEXT_TYPE_NUMERIC_UNSIGNED_INT,
                tooltip = "Do you want the queue to auto accept? Unneeded if you already have kill counter's auto accept enabled.",
                default = TVS.defaults.AutoAcceptQueue,
                getFunc = function() return TVS.SV.AutoAcceptQueue end,
                setFunc = function(value)
                    EVENT_MANAGER:UnregisterForEvent(TVS.name, EVENT_CAMPAIGN_QUEUE_STATE_CHANGED)
                    TVS.SV.AutoAcceptQueue = value
                end,
            })

    table.insert(options,
            {
                type = "checkbox",
                name = "Midyear Mayhem campaigns",
                textType = TEXT_TYPE_NUMERIC_UNSIGNED_INT,
                tooltip = "Check if you want to show midyear campaigns. Requires you /reload after",
                default = TVS.defaults.midyear,
                getFunc = function() return TVS.SV.midyear end,
                setFunc = function(value)
                    LAM.util.ShowConfirmationDialog("Enable midyear campaigns?","You must reload your UI to see midyear campaigns. It will reset your selected campaigns", function()
                        zo_callLater(function()
                            TVS.SV.midyear = value
                            TVS.SV.ICCamp = TVS.defaults.ICCamp
                            TVS.SV.CyroCamp = TVS.defaults.CyroCamp
                            ReloadUI()
                        end, 200)
                    end)
                end,
            })

    table.insert(options, {
        type = "header",
        name = "Time/Life Savers",

    })

    table.insert(options,
            {
                type = "checkbox",
                name = "Auto leave when telvar limit reached",
                textType = TEXT_TYPE_NUMERIC_UNSIGNED_INT,
                tooltip = "Only triggers if you gain telvar, and the limit exceeds the set amount below. Wont trigger if you withdraw from your bank or something so be careful",
                default = TVS.defaults.AutoQueueOut,
                getFunc = function() return TVS.SV.AutoQueueOut end,
                setFunc = function(value)
                    TVS.SV.AutoQueueOut = value
                end,
            })

    table.insert(options, {
        type = "editbox",
        name = "Telvar limit",
        tooltip = "If you kill a mob or player and your telvar gained exceeds this int, you will queue out",
        textType = TEXT_TYPE_NUMERIC_UNSIGNED_INT,
        default = TVS.defaults.TelvarCap,
        getFunc = function() return TVS.SV.TelvarCap end,
        setFunc = function(text)
            local value = tonumber(text)
            if (value <= 0) then value = 1 end
            TVS.SV.TelvarCap = value
        end,
    })

    table.insert(options,
            {
                type = "checkbox",
                name = "Group queue ",
                textType = TEXT_TYPE_NUMERIC_UNSIGNED_INT,
                tooltip = "Determines if you group queue if youre the group leader when you hit the keybind or reach your cap",
                default = TVS.defaults.GroupQueue,
                getFunc = function() return TVS.SV.GroupQueue end,
                setFunc = function(value)
                    TVS.SV.GroupQueue = value
                end,
            })

    table.insert(options,
            {
                type = "checkbox",
                name = "Auto kick offline (IMPORTANT) ",
                textType = TEXT_TYPE_NUMERIC_UNSIGNED_INT,
                tooltip = "To group queue you need to have no offline members in your group. By having this disabled, you will not be able to queue if you have an offline person in your group",
                default = TVS.defaults.AutoKickOffline,
                getFunc = function() return TVS.SV.AutoKickOffline end,
                setFunc = function(value)
                    TVS.SV.AutoKickOffline = value
                end,
            })
    table.insert(options,
            {
                type = "checkbox",
                name = "Auto loot imperial fragments",
                textType = TEXT_TYPE_NUMERIC_UNSIGNED_INT,
                tooltip = "Determines if the addon will auto loot imperial fragments when opening a loot menu",
                default = TVS.defaults.AutoLootKeyFrags,
                getFunc = function() return TVS.SV.AutoLootKeyFrags end,
                setFunc = function(value)
                    TVS.SV.AutoLootKeyFrags = value
                end,
            })
    table.insert(options,
            {
                type = "checkbox",
                name = "Auto loot gold in IC",
                textType = TEXT_TYPE_NUMERIC_UNSIGNED_INT,
                tooltip = "Determines if the addon will auto loot gold when opening a loot menu",
                default = TVS.defaults.AutoLootGold,
                getFunc = function() return TVS.SV.AutoLootGold end,
                setFunc = function(value)
                    TVS.SV.AutoLootGold = value
                end,
            })

    table.insert(options,
            {
                type = "checkbox",
                name = "Auto loot telvar (containers and chests) in IC",
                textType = TEXT_TYPE_NUMERIC_UNSIGNED_INT,
                tooltip = "Determines if the addon will auto loot telvar when opening a loot menu",
                default = TVS.defaults.AutoLootTelvar,
                getFunc = function() return TVS.SV.AutoLootTelvar end,
                setFunc = function(value)
                    TVS.SV.AutoLootTelvar = value
                end,
            })

    table.insert(options,
            {
                type = "checkbox",
                name = "Skip bank dialog in IC",
                textType = TEXT_TYPE_NUMERIC_UNSIGNED_INT,
                tooltip = "Will skip the bank dialog if youre in IC.",
                default = TVS.defaults.SkipBankDialog,
                getFunc = function() return TVS.SV.SkipBankDialog end,
                setFunc = function(value)
                    TVS.SV.SkipBankDialog = value
                end,
            })

    table.insert(options, {
        type = "header",
        name = "Auto Deposits and Withdraw from bank",

    })

    table.insert(options,
            {
                type = "checkbox",
                name = "Auto deposit telvar into bank",
                textType = TEXT_TYPE_NUMERIC_UNSIGNED_INT,
                tooltip = "If your current carried telvar exceeds your desired amount, deposit the excess",
                default = TVS.defaults.AutoDepoTelvar,
                getFunc = function() return TVS.SV.AutoDepoTelvar end,
                setFunc = function(value)
                    TVS.SV.AutoDepoTelvar = value
                end,
            })

    table.insert(options,
            {
                type = "checkbox",
                name = "Auto withdraw telvar from bank",
                textType = TEXT_TYPE_NUMERIC_UNSIGNED_INT,
                tooltip = "If your current carried telvar is below your desired amount, withdraw the amount to reach it",
                default = TVS.defaults.AutoWithdrawTelvar,
                getFunc = function() return TVS.SV.AutoWithdrawTelvar end,
                setFunc = function(value)
                    TVS.SV.AutoWithdrawTelvar = value
                end,
            })

    table.insert(options, {
        type = "editbox",
        name = "Desired carried Telvar ",
        tooltip = "The amount you want to carry (for auto depos and withdraws)",
        textType = TEXT_TYPE_NUMERIC_UNSIGNED_INT,
        default = TVS.defaults.DesiredTelvarAmount,
        getFunc = function() return TVS.SV.DesiredTelvarAmount end,
        setFunc = function(text)
            local amount = tonumber(text)
            -- If you really really really want to take out more than 10k for some reason with this addon, remove the if statement at your own risk
            if (amount < 0) or (amount > 10000) then
                amount = 0
                d("Invalid amount. Must be between 0 and 10000")
            end
            TVS.SV.DesiredTelvarAmount = amount
        end,
    })


    table.insert(options, {
        type = "header",
        name = "Bank Menu",

    })

    table.insert(options,
            {
                type = "checkbox",
                name = "Bank Scene",
                textType = TEXT_TYPE_NUMERIC_UNSIGNED_INT,
                tooltip = "Determines if the bank scene shows up or not",
                default = TVS.defaults.BankScene,
                getFunc = function() return TVS.SV.BankScene end,
                setFunc = function(value)
                    if (value == false) then TVS.CloseBank() end
                    TVS.SV.BankScene = value
                end,
            })

    table.insert(options,
            {
                type = "checkbox",
                name = "Dragable",
                textType = TEXT_TYPE_NUMERIC_UNSIGNED_INT,
                tooltip = "",
                default = TVS.defaults.dragable,
                getFunc = function() return TVS.SV.dragable end,
                setFunc = function(value)
                    TVS.SV.dragable = value
                    TVS.UpdateAnchors()
                end,
            })


    table.insert(options, {
        type = "button",
        name = "reset position to defaults",
        func = function ()
            TVS.SV.locationy = TVS.defaults.locationy
            TVS.SV.locationx = TVS.defaults.locationx
            TVS.UpdateAnchors()

        end
    })

    table.insert(options, {
        type = "button",
        name = "reset ALL SETTINGS",
        func = function ()
            LAM.util.ShowConfirmationDialog("Reset all settings to defaults?","Requires a UI reload", function()
                zo_callLater(function()
                    -- lol
                    TVS.SV.locationy = TVS.defaults.locationy
                    TVS.SV.locationx = TVS.defaults.locationx
                    TVS.UpdateAnchors()

                    TVS.SV.AutoKickOffline = TVS.defaults.AutoKickOffline
                    TVS.SV.midyear = TVS.defaults.midyear
                    TVS.SV.LastICCamp = TVS.defaults.LastICCamp
                    TVS.SV.AutoAcceptQueue = TVS.defaults.AutoAcceptQueue
                    TVS.SV.SkipBankDialog = TVS.defaults.SkipBankDialog
                    TVS.SV.BackupCamp =  TVS.defaults.BackupCamp
                    TVS.SV.UseBackup = TVS.defaults.UseBackup
                    TVS.SV.AutoLootGold = TVS.defaults.AutoLootGold
                    TVS.SV.AutoLootTelvar = TVS.defaults.AutoLootTelvar
                    TVS.SV.AutoLootKeyFrags = TVS.defaults.AutoLootKeyFrags
                    TVS.SV.notifications = TVS.defaults.notifications
                    TVS.SV.dragable = TVS.defaults.dragable
                    TVS.SV.locationx = TVS.defaults.locationx
                    TVS.SV.locationy = TVS.defaults.locationy
                    TVS.SV.BankScene = TVS.defaults.BankScene
                    TVS.SV.AutoDepoTelvar = TVS.defaults.AutoDepoTelvar
                    TVS.SV.AutoWithdrawTelvar = TVS.defaults.AutoWithdrawTelvar
                    TVS.SV.DesiredTelvarAmount = TVS.defaults.DesiredTelvarAmount
                    TVS.SV.ICCamp = TVS.defaults.ICCamp
                    TVS.SV.CyroCamp = CyroCamp
                    TVS.SV.AutoQueueOut = TVS.defaults.AutoQueueOut
                    TVS.SV.TelvarCap = TVS.defaults.TelvarCap
                    TVS.SV.GroupQueue = TVS.defaults.GroupQueue
                    ReloadUI()
                end, 100)
            end)
        end
    })



    -- Registering Panel and Options
    local controlPanel = LAM:RegisterAddonPanel(panelName,panelData)
    LAM:RegisterOptionControls(panelName,options)
end
