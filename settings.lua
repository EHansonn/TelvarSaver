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

    table.insert(options, {
        type = "header",
        name = "Campaign Options",

    })
    table.insert(options,
            {
                type = "dropdown",
                name = "Preferred Cyro Campaign",
                textType = TEXT_TYPE_NUMERIC_UNSIGNED_INT,
                tooltip = "pick ya poison",
                choices = {'Greyhost','Blackreach','Ravenswatch',"Quagmire","Fields of regret","Ashpit","Evergloam"},
                default = TVS.defaults.CyroCamp,
                getFunc = function() return TVS.SV.CyroCamp end,
                setFunc = function(value)
                    TVS.SV.CyroCamp = value
                end,
            })

    table.insert(options,
            {
                type = "dropdown",
                name = "Preferred IC Campaign",
                textType = TEXT_TYPE_NUMERIC_UNSIGNED_INT,
                tooltip = "nocp or cp ic",
                choices = {'NOCP','CP',"Dragonfire","Legion Zero"},
                default = TVS.defaults.ICCamp,
                getFunc = function() return TVS.SV.ICCamp end,
                setFunc = function(value)
                    TVS.SV.ICCamp = value
                end,
            })

    table.insert(options,
            {
                type = "checkbox",
                name = "Use backup campaign if theres a queue?",
                textType = TEXT_TYPE_NUMERIC_UNSIGNED_INT,
                tooltip = "If your preferred camp has a queue it will unqueue you and requeue you for the backup",
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
                choices = {'Greyhost','Blackreach','Ravenswatch',"Quagmire","Fields of regret","Ashpit","Evergloam"},
                default = "Ravenswatch",
                getFunc = function() return TVS.SV.BackupCamp end,
                setFunc = function(value)
                    TVS.SV.BackupCamp = value
                end,
            })

    table.insert(options,
            {
                type = "checkbox",
                name = "Auto accept queue?",
                textType = TEXT_TYPE_NUMERIC_UNSIGNED_INT,
                tooltip = "Do you want the queue to auto accept?",
                default = TVS.defaults.AutoAcceptQueue,
                getFunc = function() return TVS.SV.AutoAcceptQueue end,
                setFunc = function(value)
                    EVENT_MANAGER:UnregisterForEvent(TVS.name, EVENT_CAMPAIGN_QUEUE_STATE_CHANGED)
                    TVS.SV.AutoAcceptQueue = value
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
                tooltip = "Only triggers if you kill something, gain telvar, and the limit exceeds the set amount below. Wont trigger if you withdraw from your bank or something so be careful",
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
            TVS.SV.TelvarCap = tonumber(text)
        end,
    })

    table.insert(options,
            {
                type = "checkbox",
                name = "Group queue when queueing ",
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
                name = "Auto loot key frags",
                textType = TEXT_TYPE_NUMERIC_UNSIGNED_INT,
                tooltip = "Determines if the addon will auto loot key frags when opening a loot menu",
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
                name = "Auto loot telvar (from containers) in IC",
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
                name = "Auto deposit telvar to bank",
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
        tooltip = "The amount you want to carry",
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
                name = "Dragable?",
                textType = TEXT_TYPE_NUMERIC_UNSIGNED_INT,
                tooltip = "",
                default = TVS.defaults.dragable,
                getFunc = function() return TVS.SV.dragable end,
                setFunc = function(value)
                    TVS.SV.dragable = value
                    TVS.UpdateAnchors()
                end,
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
        type = "button",
        name = "reset position to defaults",
        func = function ()
            TVS.SV.locationy = TVS.defaults.locationy
            TVS.SV.locationx = TVS.defaults.locationx
            TVS.UpdateAnchors()

        end
    })




    -- Registering Panel and Options
    local controlPanel = LAM:RegisterAddonPanel(panelName,panelData)
    LAM:RegisterOptionControls(panelName,options)
end
