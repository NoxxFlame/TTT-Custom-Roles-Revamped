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

local function DrawTask(task, height, isShadow)
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

    surface.DrawRect((margin * 2) + 2 + offset, height + 2 + offset, 2, checkboxSize)
    surface.DrawRect((margin * 2) + 2 + offset, height + 2 + offset, checkboxSize, 2)
    surface.DrawRect((margin * 2) + 2 + offset, height + checkboxSize + offset, checkboxSize, 2)
    surface.DrawRect((margin * 2) + checkboxSize + offset, height + 2 + offset, 2, checkboxSize)

    surface.SetFont("TraitorStateSmall")
    surface.SetTextPos((margin * 3) + checkboxSize + offset, height + offset)
    surface.DrawText(name)

    local nameWidth, nameHeight = surface.GetTextSize(name)
    if completed then
        surface.DrawRect((margin * 3) + checkboxSize + offset, height + (nameHeight / 2) + 1 + offset, nameWidth, 2)
    end

    height = height + nameHeight + (margin / 2)

    surface.SetFont("UseHint")
    surface.SetTextPos(margin * 3 + offset, height + offset)
    surface.DrawText(desc)

    local descWidth, descHeight = surface.GetTextSize(desc)
    if completed then
        surface.DrawRect(margin * 3 + offset, height + (descHeight / 2) + 1 + offset, descWidth, 1)
    end

    height = height + descHeight + margin
    return height
end

hook.Add("HUDPaint", "Taskmaster_HUDPaint", function()
    if GetRoundState() ~= ROUND_ACTIVE then return end

    if not client then
        client = LocalPlayer()
    end
    if not client:IsTaskmaster() then return end

    local height = margin * 2

    for _, id in ipairs(client.taskmasterKillTasks) do
        DrawTask(TASKMASTER.killTasks[id], height, true)
        height = DrawTask(TASKMASTER.killTasks[id], height)
    end

    for _, id in ipairs(client.taskmasterMiscTasks) do
        DrawTask(TASKMASTER.miscTasks[id], height, true)
        height = DrawTask(TASKMASTER.miscTasks[id], height)
    end
end)