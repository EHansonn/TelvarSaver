
function TVS.TenThousand()
    TVS.TelvarButton(10000)
end

function TVS.OneThousand()
    TVS.TelvarButton(1000)
end

function TVS.Zero()
    TVS.TelvarButton(0)
end

function TVS.HideUi()
    --TVSView:SetAlpha(0)
    TVSView:SetHidden(true)
end

function TVS.SetHidden()
    TVS.HideUi()
    TVS.SV.BankScene = false
end

function TVS.UpdateText()
    local currentTelvarOnChar = GetCarriedCurrencyAmount(CURT_TELVAR_STONES)
    TVSViewCurrentText:SetText("Current: " .. "|c8080ff" .. tostring(currentTelvarOnChar) .."|r" )
end

function TVS.SaveLocation()

    TVS.SV.locationx = TVSView:GetLeft()
    TVS.SV.locationy = TVSView:GetTop()

end

function TVS.UpdateAnchors()

    TVSView:ClearAnchors()
    TVSView:SetAnchor(TOPLEFT,GuiRoot,TOPLEFT,TVS.SV.locationx,TVS.SV.locationy)
    TVSView:SetMovable(TVS.SV.dragable)
end