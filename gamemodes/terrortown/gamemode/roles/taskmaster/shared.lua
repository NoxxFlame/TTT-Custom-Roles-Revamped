AddCSLuaFile()

------------------
-- ROLE CONVARS --
------------------

CreateConVar("ttt_taskmaster_kill_tasks", "1", FCVAR_REPLICATED, "The number of kill tasks assigned to the Taskmaster", 0, 10)
CreateConVar("ttt_taskmaster_misc_tasks", "2", FCVAR_REPLICATED, "The number of miscellaneous tasks assigned to the Taskmaster", 0, 10)

ROLE_CONVARS[ROLE_TASKMASTER] = {}

table.insert(ROLE_CONVARS[ROLE_TASKMASTER], {
    cvar = "ttt_taskmaster_kill_tasks",
    type = ROLE_CONVAR_TYPE_NUM,
    decimal = 0
})
table.insert(ROLE_CONVARS[ROLE_TASKMASTER], {
    cvar = "ttt_taskmaster_misc_tasks",
    type = ROLE_CONVAR_TYPE_NUM,
    decimal = 0
})

-----------------------
-- TASK REGISTRATION --
-----------------------

TASKMASTER = {
    killTasks = {},
    miscTasks = {}
}

function TASKMASTER.RegisterTask(task)
    task.id = task.id or task.Id or task.ID

    if TASKMASTER.tasks[task.id] then
        ErrorNoHalt("ERROR: Attempted to register Taskmaster task '" .. task.id .. "' with duplicate task ID.\n")
        return
    end

    local cvarName = "ttt_taskmaster_" .. task.id .. "_enabled"
    local enabled = CreateConVar(cvarName, 1, FCVAR_REPLICATED)
    task.Enabled = function()
        return enabled:GetBool()
    end
    table.insert(ROLE_CONVARS[ROLE_TASKMASTER], {
        cvar = cvarName,
        type = ROLE_CONVAR_TYPE_BOOL
    })

    if task.isKillTask then
        TASKMASTER.killTasks[task.id] = task
    else
        TASKMASTER.miscTasks[task.id] = task
    end
end

local function AddTaskFiles(root)
    local taskFiles, _ = file.Find(root .. "*.lua", "LUA")
    for _, fil in ipairs(taskFiles) do
        include(root .. fil)
        if SERVER then AddCSLuaFile(root .. fil) end
    end
end

AddTaskFiles("terrortown/gamemode/roles/taskmaster/tasks/") -- Internal tasks
AddTaskFiles("taskmastertasks/") -- External tasks