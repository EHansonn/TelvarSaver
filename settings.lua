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
                default = "Ravenswatch",
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
                default = "NOCP",
                getFunc = function() return TVS.SV.ICCamp end,
                setFunc = function(value)
                    TVS.SV.ICCamp = value
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
        tooltip = "If you kill a mob and your telvar gained exceeds this int, you will queue out",
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
    table.insert(options, {
        type = "header",
        name = "Auto Telvar Bank Depo and Withdraws on bank open",

    })

    table.insert(options,
            {
                type = "checkbox",
                name = "Auto deposit telvar from bank",
                textType = TEXT_TYPE_NUMERIC_UNSIGNED_INT,
                tooltip = "If your current carried telavr exceeds your desired amount, deposit the excess",
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
                tooltip = "If your current carried telavr is below your desired amount, withdraw the amount to reach it",
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
        name = "Bank Scene",

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


    table.insert(options, {
        type = "description",
        text = "IMPORTANT!!!! Check your controls for the keybind, its unbound by default",

    })

    -- Registering Panel and Options
    local controlPanel = LAM:RegisterAddonPanel(panelName,panelData)
    LAM:RegisterOptionControls(panelName,options)
end
