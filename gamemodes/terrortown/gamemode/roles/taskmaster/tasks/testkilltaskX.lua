local TASK = {}

TASK.id = "testkilltaskX"
TASK.name = "Test Kill Task X"
TASK.description = "Test Kill Task X Description"
TASK.isKillTask = true

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