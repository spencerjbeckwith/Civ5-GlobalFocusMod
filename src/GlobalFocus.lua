ContextPtr:SetHide(true);

-- Add menu to additional information dropdown
LuaEvents.AdditionalInformationDropdownGatherEntries.Add(
    function(entries)
        table.insert(entries, {
            text = Locale.ConvertTextKey("TXT_KEY_GLOBALFOCUS_TITLE"),
            call = function()
                ContextPtr:SetHide(false);
            end,
        });
    end
);
LuaEvents.RequestRefreshAdditionalInformationDropdownEntries();

-- Let the menu be closed with the escape key
ContextPtr:SetInputHandler(
    function(uiMsg, wParam, lParam)
        if (uiMsg == KeyEvents.KeyDown) then
            if (wParam == Keys.VK_ESCAPE) then
                ContextPtr:SetHide(true);
                return true;
            end
        end
        return false;
    end
);