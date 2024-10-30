AddCSLuaFile()

local plymeta = FindMetaTable("Player")

util.AddNetworkString("TTT_TaskmasterRerollTask")

-------------
-- CONVARS --
-------------

local taskmaster_kill_tasks = GetConVar("ttt_taskmaster_kill_tasks")
local taskmaster_misc_tasks = GetConVar("ttt_taskmaster_misc_tasks")

---------------------
-- TASK ASSIGNMENT --
---------------------

function plymeta:AssignTask(isKillTask, index)
    if not self:IsTaskmaster() then return end

    local taskList = isKillTask and TASKMASTER.killTasks or TASKMASTER.miscTasks
    local taskIds = table.GetKeys(taskList)
    local activeTasksName = isKillTask and "taskmasterKillTasks" or "taskmasterMiscTasks"

    for _, activeId in ipairs(self[activeTasksName]) do
        table.RemoveByValue(taskIds, activeId)
    end
    for _, rerolledId in ipairs(self.taskmasterRerolledTasks) do
        table.RemoveByValue(taskIds, rerolledId)
    end
    table.Shuffle(taskIds)

    for _, id in ipairs(taskIds) do
        if taskList[id].CanAssignTask(self) then
            taskList[id].OnTaskAssigned(self)

            if index then
                table.insert(self[activeTasksName], index, id)
            else
                table.insert(self[activeTasksName], id)
            end
            self:SetProperty(activeTasksName, self[activeTasksName], self)
            return taskList[id]
        end
    end
    -- TODO: Handle edge case where there are no valid tasks. Maybe we need to change their role? Or just have a free fallback task?
    return false
end

function plymeta:RemoveTask(taskId)
    if not self:IsTaskmaster() then return end

    local isKillTask = TASKMASTER.killTasks[taskId] and true or false
    local taskList = isKillTask and TASKMASTER.killTasks or TASKMASTER.miscTasks
    local activeTasksName = isKillTask and "taskmasterKillTasks" or "taskmasterMiscTasks"

    taskList[taskId].OnTaskRemoved(self)

    table.RemoveByValue(self[activeTasksName], taskId)
    self:SetProperty(activeTasksName, self[activeTasksName], self)
end

function plymeta:RerollTask(taskId, free)
    if not self:IsTaskmaster() then return end
    if not free and self:GetCredits() == 0 then return end

    local isKillTask = TASKMASTER.killTasks[taskId] and true or false
    local activeTasksName = isKillTask and "taskmasterKillTasks" or "taskmasterMiscTasks"
    local index = table.KeyFromValue(self[activeTasksName], taskId)
    if not index then return end

    table.insert(self.taskmasterRerolledTasks, taskId)
    self:SetProperty("taskmasterRerolledTasks", self.taskmasterRerolledTasks, self)

    self:AssignTask(isKillTask, index)
    self:RemoveTask(taskId)

    if not free then
        self:SubtractCredits(1)
    end
end

net.Receive("TTT_TaskmasterRerollTask", function(len, ply)
    ply:RerollTask(net.ReadString())
end)

function plymeta:CompleteTask(taskId)
    if not self:IsActiveTaskmaster() then return end

    local isKillTask = TASKMASTER.killTasks[taskId] and true or false
    local taskList = isKillTask and TASKMASTER.killTasks or TASKMASTER.miscTasks
    local activeTasksName = isKillTask and "taskmasterKillTasks" or "taskmasterMiscTasks"
    if table.HasValue(self[activeTasksName], taskId) then
        taskList[taskId].OnTaskComplete(self)
        table.insert(self.taskmasterCompletedTasks, taskId)
        self:SetProperty("taskmasterCompletedTasks", self.taskmasterCompletedTasks, self)

        local activeTasksList = table.Copy(self.taskmasterKillTasks)
        table.Add(activeTasksList, self.taskmasterMiscTasks)
        for _, id in ipairs(self.taskmasterCompletedTasks) do
            if table.HasValue(activeTasksList, id) then
                table.RemoveByValue(activeTasksList, id)
            else
                break
            end
        end
        if #activeTasksList == 0 then
            self:SetProperty("taskmasterShouldWin", true)
            -- TODO: Alert the player that they have finished all their tasks
        end
        return true
    end
    return false
end

ROLE_ON_ROLE_ASSIGNED[ROLE_TASKMASTER] = function(ply)
    ply:SetProperty("taskmasterKillTasks", {}, ply)
    ply:SetProperty("taskmasterMiscTasks", {}, ply)
    ply:SetProperty("taskmasterCompletedTasks", {}, ply)
    ply:SetProperty("taskmasterRerolledTasks", {}, ply)
    for _ = 1, taskmaster_kill_tasks:GetInt() do
        ply:AssignTask(true)
    end
    for _ = 1, taskmaster_misc_tasks:GetInt() do
        ply:AssignTask(false)
    end
end

------------------
-- WIN BLOCKING --
------------------

hook.Add("TTTWinCheckBlocks", "Taskmaster_TTTWinCheckBlocks", function(win_blocks)
    table.insert(win_blocks, function(win_type)
        if win_type == WIN_NONE then return win_type end

        local taskmaster = player.GetLivingRole(ROLE_TASKMASTER)
        if not IsPlayer(taskmaster) then return win_type end

        if taskmaster.taskmasterShouldWin then return win_type end

        if win_type == WIN_TRAITOR or win_type == WIN_INNOCENT or win_type == WIN_MONSTER then
            return WIN_NONE
        end
    end)
end)

-------------
-- CLEANUP --
-------------

local function CleanupTasks(ply)
    ply:ClearProperty("taskmasterKillTasks", ply)
    ply:ClearProperty("taskmasterMiscTasks", ply)
    ply:ClearProperty("taskmasterCompletedTasks", ply)
    ply:ClearProperty("taskmasterRerolledTasks", ply)
    ply:ClearProperty("taskmasterShouldWin")
end

hook.Add("TTTPrepareRound", "Taskmaster_TTTPrepareRound", function()
    for _, ply in player.Iterator() do
        CleanupTasks(ply)
    end
end)

hook.Add("TTTPlayerRoleChanged", "Taskmaster_TTTPlayerRoleChanged", function(ply, oldRole, newRole)
    if not ply:Alive() or ply:IsSpec() then return end

    if oldRole == ROLE_TASKMASTER and oldRole ~= newRole then
        CleanupTasks(ply)
    end
end)