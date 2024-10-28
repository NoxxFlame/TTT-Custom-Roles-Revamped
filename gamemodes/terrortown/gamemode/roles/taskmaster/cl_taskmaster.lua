----------------
-- WIN CHECKS --
----------------

hook.Add("TTTScoringSecondaryWins", "Taskmaster_TTTScoringSecondaryWins", function(wintype, secondary_wins)
    for _, ply in player.Iterator() do
        if not ply:IsTaskmaster() then continue end
        if ply["taskmasterShouldWin"] then
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

    local offsetX, offsetY

    for _, id in ipairs(client["taskmasterKillTasks"]) do
        local dx, dy = TASKMASTER.killTasks[id].DrawHUD(client, offsetX, offsetY)
        offsetX = offsetX + dx
        offsetY = offsetY + dy
    end

    for _, id in ipairs(client["taskmasterMiscTasks"]) do
        local dx, dy = TASKMASTER.miscTasks[id].DrawHUD(client, offsetX, offsetY)
        offsetX = offsetX + dx
        offsetY = offsetY + dy
    end
end)