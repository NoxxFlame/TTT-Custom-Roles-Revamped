------------------
-- TRANSLATIONS --
------------------

hook.Add("Initialize", "Taskmaster_Translations_Initialize", function()
    -- ConVars
    LANG.AddToLanguage("english", "taskmaster_config_x_pos", "Task list X (horizontal) position")
    LANG.AddToLanguage("english", "taskmaster_config_y_pos", "Task list Y (vertical) position")
end)

-------------
-- CONVARS --
-------------

local xOffset = CreateClientConVar("ttt_taskmaster_list_x_pos", "10", true, false, "The X (horizontal) position of the Taskmaster's task list HUD", 0, ScrW())
local yOffset = CreateClientConVar("ttt_taskmaster_list_y_pos", "10", true, false, "The Y (vertical) position of the Taskmaster's task list HUD", 0, ScrH())

hook.Add("TTTSettingsRolesTabSections", "Taskmaster_TTTSettingsRolesTabSections", function(role, parentForm)
    if role ~= ROLE_TASKMASTER then return end

    parentForm:NumSlider(LANG.GetTranslation("taskmaster_config_x_pos"), "ttt_taskmaster_list_x_pos", 0, ScrW(), 0)
    parentForm:NumSlider(LANG.GetTranslation("taskmaster_config_y_pos"), "ttt_taskmaster_list_y_pos", 0, ScrH(), 0)
    return true
end)


----------------
-- WIN CHECKS --
----------------

hook.Add("TTTScoringSecondaryWins", "Taskmaster_TTTScoringSecondaryWins", function(wintype, secondary_wins)
    for _, ply in player.Iterator() do
        if not ply:IsTaskmaster() then continue end
        if ply.taskmasterShouldWin then
            table.insert(secondary_wins, ROLE_TASKMASTER)
            break
        end
    end
end)

---------
-- HUD --
---------

local client

local margin = 10
local checkboxSize = 21
local maxHeight, maxWidth = 0, 0

local function DrawTask(task, height, isShadow)
    local xPos = xOffset:GetInt()

    local offset = 0
    surface.SetDrawColor(255, 255, 255)
    surface.SetTextColor(255, 255, 255)

    if isShadow then
        offset = 2
        surface.SetDrawColor(0, 0, 0)
        surface.SetTextColor(0, 0, 0)
    end

    local name = task.Name(client)
    local desc = task.Description(client)
    local completed = table.HasValue(client.taskmasterCompletedTasks, task.id)

    -- The checkboxes don't naturally align with the text, thus the '+2's everywhere to make it line up
    surface.DrawRect(xPos + margin + 2 + offset, height + 2 + offset, 2, checkboxSize)
    surface.DrawRect(xPos + margin + 2 + offset, height + 2 + offset, checkboxSize, 2)
    surface.DrawRect(xPos + margin + 2 + offset, height + checkboxSize + offset, checkboxSize, 2)
    surface.DrawRect(xPos + margin + checkboxSize + offset, height + 2 + offset, 2, checkboxSize)

    surface.SetFont("TraitorStateSmall")
    surface.SetTextPos(xPos + (margin * 2) + checkboxSize + offset, height + offset)
    surface.DrawText(name)

    local nameWidth, nameHeight = surface.GetTextSize(name)
    if completed then
        -- Shifting the strikethrough lines down one pixel makes it look much nicer with lowercase letters
        surface.DrawRect(xPos + (margin * 2) + checkboxSize + offset, height + (nameHeight / 2) + 1 + offset, nameWidth, 2)
        if not isShadow then
            -- Drawing the checkmark shadows over the checkbox helps it to stand out
            surface.SetDrawColor(0, 0, 0)
            draw.NoTexture()
            surface.DrawPoly({
                {x = xPos + margin + 5, y = height + 13},
                {x = xPos + margin + 9, y = height + 10},
                {x = xPos + margin + 14, y = height + 15},
                {x = xPos + margin + 14, y = height + 21}
            })
            surface.DrawPoly({
                {x = xPos + margin + 14, y = height + 21},
                {x = xPos + margin + 14, y = height + 15},
                {x = xPos + margin + 26, y = height + 3},
                {x = xPos + margin + 29, y = height + 6}
            })
            surface.SetDrawColor(0, 192, 0)
            surface.DrawPoly({
                {x = xPos + margin + 4, y = height + 11},
                {x = xPos + margin + 8, y = height + 8},
                {x = xPos + margin + 13, y = height + 13},
                {x = xPos + margin + 13, y = height + 19}
            })
            surface.DrawPoly({
                {x = xPos + margin + 13, y = height + 19},
                {x = xPos + margin + 13, y = height + 13},
                {x = xPos + margin + 25, y = height + 1},
                {x = xPos + margin + 28, y = height + 4}
            })
            surface.SetDrawColor(255, 255, 255)
        end
    end

    if (margin * 3) + checkboxSize + nameWidth > maxWidth then maxWidth = (margin * 3) + checkboxSize + nameWidth end

    height = height + nameHeight + (margin / 2)

    surface.SetFont("UseHint")
    surface.SetTextPos(xPos + (margin * 2) + offset, height + offset)
    surface.DrawText(desc)

    local descWidth, descHeight = surface.GetTextSize(desc)
    if completed then
        -- Shifting the strikethrough lines down one pixel makes it look much nicer with lowercase letters
        surface.DrawRect(xPos + (margin * 2) + offset, height + (descHeight / 2) + 1 + offset, descWidth, 1)
    end

    if (margin * 3) + descWidth > maxWidth then maxWidth = (margin * 3) + descWidth end

    height = height + descHeight + margin
    return height
end

hook.Add("HUDPaintBackground", "Taskmaster_HUDPaintBackground", function()
    if GetRoundState() ~= ROUND_ACTIVE then return end
    if maxHeight == 0 or maxWidth == 0 then return end

    if not client then
        client = LocalPlayer()
    end
    if not client:IsActiveTaskmaster() then return end

    -- Add 2 to the maxWidth here to account for the text shadows
    draw.RoundedBox(8, xOffset:GetInt(), yOffset:GetInt(), maxWidth + 2, maxHeight, Color(0, 0, 10, 200))
    maxWidth, maxHeight = 0, 0
end)

hook.Add("HUDPaint", "Taskmaster_HUDPaint", function()
    if GetRoundState() ~= ROUND_ACTIVE then return end

    if not client then
        client = LocalPlayer()
    end
    if not client:IsActiveTaskmaster() then return end

    local height = yOffset:GetInt() + margin

    for _, id in ipairs(client.taskmasterKillTasks) do
        DrawTask(TASKMASTER.killTasks[id], height, true)
        height = DrawTask(TASKMASTER.killTasks[id], height)
    end

    for _, id in ipairs(client.taskmasterMiscTasks) do
        DrawTask(TASKMASTER.miscTasks[id], height, true)
        height = DrawTask(TASKMASTER.miscTasks[id], height)
    end

    maxHeight = height - yOffset:GetInt()
end)

