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

hook.Add("HUDPaint", "Taskmaster_HUDPaint", function()
    if GetRoundState() ~= ROUND_ACTIVE then return end

    if not client then
        client = LocalPlayer()
    end
    if not client:IsTaskmaster() then return end

    local offsetX, offsetY = 10, 10

    for _, id in ipairs(client.taskmasterKillTasks) do
        if TASKMASTER.killTasks[id].DrawHUD then
            local dx, dy = TASKMASTER.killTasks[id].DrawHUD(client, offsetX, offsetY)
            if dx then offsetX = offsetX + dx end
            if dy then offsetY = offsetY + dy end
        end
    end

    for _, id in ipairs(client.taskmasterMiscTasks) do
        if TASKMASTER.miscTasks[id].DrawHUD then
            local dx, dy = TASKMASTER.miscTasks[id].DrawHUD(client, offsetX, offsetY)
            if dx then offsetX = offsetX + dx end
            if dy then offsetY = offsetY + dy end
        end
    end
end)