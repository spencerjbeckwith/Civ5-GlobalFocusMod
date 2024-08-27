---------------------------------------
-- Persistence functions
---------------------------------------
function GetCurrentFocus()
    local save = Modding.OpenSaveData();
    return save.GetValue("CurrentFocus") or -1;
end

function SaveCurrentFocus(iFocus)
    local save = Modding.OpenSaveData();
    save.SetValue("CurrentFocus", iFocus);
end

---------------------------------------

-- -1/any other value: default
-- 0: food
-- 1: production
-- 2: gold
-- 3: great people
-- 4: science
-- 5: culture
-- 8: faith
function SetFocusTo(iFocus)
    for city in Players[Game.GetActivePlayer()]:Cities() do
        SetCityTo(city, iFocus);
    end
    SaveCurrentFocus(iFocus);
    Close();
end

-- Cannot change focus for puppets, since they can't be changed manually
function SetCityTo(city, iFocus)
    if not city:IsPuppet() then
        city:SetFocusType(iFocus);
    end
end

function GetFocusName(iFocus)
    if iFocus == 0 then
        key = "TXT_KEY_GLOBALFOCUS_FOOD"
    elseif iFocus == 1 then
        key = "TXT_KEY_GLOBALFOCUS_PRODUCTION"
    elseif iFocus == 2 then
        key = "TXT_KEY_GLOBALFOCUS_GOLD"
    elseif iFocus == 3 then
        key = "TXT_KEY_GLOBALFOCUS_GREAT_PEOPLE"
    elseif iFocus == 4 then
        key = "TXT_KEY_GLOBALFOCUS_SCIENCE"
    elseif iFocus == 5 then
        key = "TXT_KEY_GLOBALFOCUS_CULTURE"
    elseif iFocus == 8 then
        key = "TXT_KEY_GLOBALFOCUS_FAITH"
    else
        key = "TXT_KEY_GLOBALFOCUS_DEFAULT"
    end
    return Locale.ConvertTextKey(key);
end

---------------------------------------
-- Context management
---------------------------------------

function Open()
    -- Update our UI to show our last-picked focus
    local currentFocus = GetCurrentFocus();
    Controls.Current:LocalizeAndSetText("TXT_KEY_GLOBALFOCUS_CURRENT_FOCUS", GetFocusName(currentFocus));

    -- Identify city names that are not on this focus and add them to our tooltip
    local differentCities = {};
    local foundDifference = false;
    for city in Players[Game.GetActivePlayer()]:Cities() do
        local cityFocus = city:GetFocusType();
        if not city:IsPuppet() and cityFocus ~= currentFocus then
            foundDifference = true;
            table.insert(differentCities, "[ICON_BULLET] "..city:GetName().." ("..GetFocusName(cityFocus)..")[NEWLINE]");
        end
    end
    if foundDifference then
        Controls.Overridden:LocalizeAndSetText("TXT_KEY_GLOBALFOCUS_OVERRIDDEN");
        Controls.Overridden:EnableToolTip(true);
        Controls.Overridden:SetToolTipString(Locale.ConvertTextKey("TXT_KEY_GLOBALFOCUS_OVERRIDE_WARNING")..table.concat(differentCities, "\n"));
    else
        Controls.Overridden:SetText("");
        Controls.Overridden:EnableToolTip(false);
    end

    ContextPtr:SetHide(false);
end

function Close()
    ContextPtr:SetHide(true);
end

Close();

---------------------------------------
-- Add callbacks to our UI
---------------------------------------
function CallbackBuilder(iFocus)
    return function()
        SetFocusTo(iFocus);
    end
end
Controls.FocusDefault:RegisterCallback(Mouse.eLClick, CallbackBuilder(-1));
Controls.FocusFood:RegisterCallback(Mouse.eLClick, CallbackBuilder(0));
Controls.FocusProduction:RegisterCallback(Mouse.eLClick, CallbackBuilder(1));
Controls.FocusGold:RegisterCallback(Mouse.eLClick, CallbackBuilder(2));
Controls.FocusGreatPeople:RegisterCallback(Mouse.eLClick, CallbackBuilder(3));
Controls.FocusScience:RegisterCallback(Mouse.eLClick, CallbackBuilder(4));
Controls.FocusCulture:RegisterCallback(Mouse.eLClick, CallbackBuilder(5));
Controls.FocusFaith:RegisterCallback(Mouse.eLClick, CallbackBuilder(8));
Controls.Close:RegisterCallback(Mouse.eLClick, Close)

---------------------------------------
-- Event listeners for city settle and annex
---------------------------------------
GameEvents.PlayerCityFounded.Add(
    function(player, cityX, cityY)
        -- Only update for human player
        if Players[player]:IsHuman() then
            local city = Map.GetPlot(cityX, cityY):GetPlotCity();
            SetCityTo(city, GetCurrentFocus());
        end
    end
);
GameEvents.CityCaptureComplete.Add(
    function(iOldOwner, bIsCapital, iX, iY, iNewOwner, iPop, bConquest)
        -- Only update for human player
        if Players[iNewOwner]:IsHuman() then
            local city = Map.GetPlot(iX, iY):GetPlotCity();
            -- Doesn't matter at this point if the city was puppeted or not
            -- The game will set it back to gold focus automatically, but this will work for those that are immediately annexed
            SetCityTo(city, GetCurrentFocus());
        end
    end
);

---------------------------------------
-- Add menu to additional information dropdown
---------------------------------------
LuaEvents.AdditionalInformationDropdownGatherEntries.Add(
    function(entries)
        table.insert(entries, {
            text = Locale.ConvertTextKey("TXT_KEY_GLOBALFOCUS_TITLE"),
            call = Open,
        });
    end
);
LuaEvents.RequestRefreshAdditionalInformationDropdownEntries();

-- Sadly, I couldn't find a way to set a hotkey to open this menu
-- Let the menu be closed with the escape key
ContextPtr:SetInputHandler(
    function(uiMsg, wParam, lParam)
        if (uiMsg == KeyEvents.KeyDown) then
            if (wParam == Keys.VK_ESCAPE) then
                Close();
                return true;
            end
        end
        return false;
    end
);