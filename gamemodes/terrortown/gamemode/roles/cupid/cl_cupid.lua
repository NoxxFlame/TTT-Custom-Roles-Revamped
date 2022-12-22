local halo = halo
local hook = hook
local ipairs = ipairs
local table = table

local GetAllPlayers = player.GetAll
local HaloAdd = halo.Add
local AddHook = hook.Add
local RemoveHook = hook.Remove
local TableInsert = table.insert
local StringUpper = string.upper

------------------
-- TRANSLATIONS --
------------------

AddHook("Initialize", "Cupid_Translations_Initialize", function()
    -- Win conditions
    LANG.AddToLanguage("english", "win_lovers", "The lovers have outlasted everyone!")
    LANG.AddToLanguage("english", "hilite_lovers_primary", "THE LOVERS WIN")
    LANG.AddToLanguage("english", "hilite_lovers_secondary", "AND THE LOVERS WIN")
    LANG.AddToLanguage("english", "ev_win_lovers", "The lovers won the round!")

    -- Scoring
    LANG.AddToLanguage("english", "score_cupid_pairnames", "{lover1} and {lover2}")
    LANG.AddToLanguage("english", "score_cupid_paired", "Paired")

    -- Popup
    LANG.AddToLanguage("english", "info_popup_cupid_jester", [[You are {role}! {traitors} think you are {ajester} and you
deal no damage. However, you can use your bow to make two
players fall in love so that they win/die together.]])
    LANG.AddToLanguage("english", "info_popup_cupid_indep", [[You are {role}! You can use your bow to make two
players fall in love so that they win/die together.]])
end)

hook.Add("TTTRolePopupRoleStringOverride", "Cupid_TTTRolePopupRoleStringOverride", function(client, roleString)
    if not IsPlayer(client) or not client:IsCupid() then return end

    if GetGlobalBool("ttt_cupids_are_independent", false) then
        return roleString .. "_indep"
    end
    return roleString .. "_jester"
end)

----------------
-- WIN CHECKS --
----------------

AddHook("TTTScoringWinTitle", "Cupid_TTTScoringWinTitle", function(wintype, wintitles, title, secondary_win_role)
    if wintype == WIN_CUPID then
        return { txt = "hilite_lovers_primary", c = ROLE_COLORS[ROLE_CUPID] }
    end
end)

AddHook("TTTScoringSecondaryWins", "Cupid_TTTScoringSecondaryWins", function(wintype, secondary_wins)
    if wintype == WIN_CUPID then return end

    for _, p in ipairs(GetAllPlayers()) do
        local lover = p:GetNWString("TTTCupidLover", "")
        if p:Alive() and lover ~= "" then
            if player.GetBySteamID64(lover):Alive() then -- This shouldn't be necessary because if one lover dies the other should too but we check just in case
                TableInsert(secondary_wins, {
                    rol = ROLE_CUPID,
                    txt = LANG.GetTranslation("hilite_lovers_secondary"),
                    col = ROLE_COLORS[ROLE_CUPID]
                })
                return
            end
        end
    end
end)

------------
-- EVENTS --
------------

AddHook("TTTEventFinishText", "Cupid_TTTEventFinishText", function(e)
    if e.win == WIN_CUPID then
        return LANG.GetTranslation("ev_win_lovers")
    end
end)

AddHook("TTTEventFinishIconText", "Cupid_TTTEventFinishIconText", function(e, win_string, role_string)
    if e.win == WIN_CUPID then
        return win_string, ROLE_STRINGS[ROLE_CUPID]
    end
end)

-------------
-- SCORING --
-------------

-- Show who the cupid paired (if anyone)
AddHook("TTTScoringSummaryRender", "Cupid_TTTScoringSummaryRender", function(ply, roleFileName, groupingRole, roleColor, name, startingRole, finalRole)
    if ply:IsCupid() then
        local lover1_sid64 = ply:GetNWString("TTTCupidTarget1", "")
        local lover2_sid64 = ply:GetNWString("TTTCupidTarget2", "")
        if lover1_sid64 == "" or lover2_sid64 == "" then return end

        local lover1 = player.GetBySteamID64(lover1_sid64)
        if not IsPlayer(lover1) then return end

        local lover2 = player.GetBySteamID64(lover2_sid64)
        if not IsPlayer(lover2) then return end

        local lover1_name = lover1:Nick()
        local lover2_name = lover2:Nick()

        return roleFileName, groupingRole, roleColor, name, LANG.GetParamTranslation("score_cupid_pairnames", {lover1=lover1_name, lover2=lover2_name}), LANG.GetTranslation("score_cupid_paired")
    end
end)

------------
-- HEARTS --
------------

AddHook("TTTShouldPlayerSmoke", "Cupid_TTTShouldPlayerSmoke", function(ply, cli, shouldSmoke, smokeColor, smokeParticle, smokeOffset)
    local target = ply:SteamID64()
    if (cli:IsCupid() and (target == cli:GetNWString("TTTCupidTarget1", "") or target == cli:GetNWString("TTTCupidTarget2", "")))
        or (target == cli:GetNWString("TTTCupidLover", "")) then
        return true, Color(230, 90, 200, 255), "particle/heart.vmt"
    end
end)

---------------
-- TARGET ID --
---------------

AddHook("TTTTargetIDPlayerRoleIcon", "Cupid_TTTTargetIDPlayerRoleIcon", function(ply, client, role, noz, colorRole, hideBeggar, showJester, hideCupid)
    if ply:IsActiveCupid() and ply:SteamID64() == client:GetNWString("TTTCupidShooter", "") then
        return ROLE_CUPID, true
    elseif ply:SteamID64() == client:GetNWString("TTTCupidLover", "") then
        return ply:GetRole(), true
    end
end)

AddHook("TTTTargetIDPlayerRing", "Cupid_TTTTargetIDPlayerRing", function(ent, client, ringVisible)
    if IsPlayer(ent) then
        if ent:IsActiveCupid() and ent:SteamID64() == client:GetNWString("TTTCupidShooter", "") then
            return true, ROLE_COLORS_RADAR[ROLE_CUPID]
        elseif ent:SteamID64() == client:GetNWString("TTTCupidLover", "") then
            return true, ROLE_COLORS_RADAR[ent:GetRole()]
        end
    end
end)

AddHook("TTTTargetIDPlayerText", "Cupid_TTTTargetIDPlayerText", function(ent, client, text, clr, secondaryText)
    if IsPlayer(ent) then
        if ent:IsActiveCupid() and ent:SteamID64() == client:GetNWString("TTTCupidShooter", "") then
            return StringUpper(ROLE_STRINGS[ROLE_CUPID]), ROLE_COLORS_RADAR[ROLE_CUPID]
        elseif ent:SteamID64() == client:GetNWString("TTTCupidLover", "") then
            return StringUpper(ROLE_STRINGS[ent:GetRole()]), ROLE_COLORS_RADAR[ent:GetRole()], "LOVER", Color(230, 90, 200, 255)
        end
    end
end)

------------------
-- HIGHLIGHTING --
------------------

local lover_vision = false
local vision_enabled = false
local client = nil

local function EnableLoverHighlights()
    AddHook("PreDrawHalos", "Cupid_Highlight_PreDrawHalos", function()
        local lover = { player.GetBySteamID64(client:GetNWString("TTTCupidLover", "")) }

        if #lover == 0 then return end

        HaloAdd(lover, Color(230, 90, 200, 255), 1, 1, 1, true, true)
    end)
end

AddHook("TTTUpdateRoleState", "Cupid_Highlight_TTTUpdateRoleState", function()
    client = LocalPlayer()
    lover_vision = GetGlobalBool("ttt_cupid_lover_vision_enable", false)
end)

AddHook("Think", "Cupid_Highlight_Think", function()
    if not IsPlayer(client) or not client:Alive() or client:IsSpec() then return end

    if lover_vision and client:GetNWString("TTTCupidLover") ~= "" then
        if not vision_enabled then
            EnableLoverHighlights()
            vision_enabled = true
        end
    else
        vision_enabled = false
    end

    if lover_vision and not vision_enabled then
        RemoveHook("PreDrawHalos", "Cupid_Highlight_PreDrawHalos")
    end
end)

--------------
-- TUTORIAL --
--------------

AddHook("TTTTutorialRoleText", "Cupid_TTTTutorialRoleText", function(role, titleLabel)
    if role == ROLE_CUPID then
        local roleTeam = player.GetRoleTeam(ROLE_CUPID, true)
        local roleTeamName, roleColor = GetRoleTeamInfo(roleTeam)
        local html = "The " .. ROLE_STRINGS[ROLE_CUPID] .. " is a <span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>" .. roleTeamName .. "</span> role that wins by making two players fall in love and helping them win together. However, players that fall in love die together and cannot survive while the other is dead."
        html = html .. "<span style='display: block; margin-top: 10px;'>They are given a <span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>bow</span> that will cause a player to fall in love when they are shot. Once two players have fallen in love they win the round by surviving until the end of the round or being the last players left standing.</span>"
        html = html .. "<span style='display: block; margin-top: 10px;'>As <span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>ROLE_STRINGS_EXT[ROLE_CUPID]</span> you do not need to survive until the end of the round to win. As long as the lovers survive you still win.</span>"
        return html
    end
end)