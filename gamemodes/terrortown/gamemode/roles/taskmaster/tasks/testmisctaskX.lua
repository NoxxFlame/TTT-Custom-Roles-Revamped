local TASK = {}

TASK.id = "testmisctaskX"
TASK.name = "Test Misc Task X"
TASK.description = "Test Misc Task X Description"

if SERVER then
    TASK.CanAssignTask = function(ply)
        return false
    end

    TASK.OnTaskAssigned = function(ply)
        ply:QueueMessage(MSG_PRINTBOTH, "Task Assigned: " .. TASK.name)
    end

    TASK.OnTaskRemoved = function(ply)
        ply:QueueMessage(MSG_PRINTBOTH, "Task Removed: " .. TASK.name)
    end

    TASK.OnTaskComplete = function(ply)
        ply:QueueMessage(MSG_PRINTBOTH, "Task Completed: " .. TASK.name)
    end
end

if CLIENT then
    TASK.DrawHUD = function(client, offsetX, offsetY)

    end
end

TASKMASTER.RegisterTask(TASK)