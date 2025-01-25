local TASK = {}

TASK.id = "testkilltask3"
TASK.isKillTask = true

TASK.Name = function(ply)
    return "Test Kill Task 3"
end

TASK.Description = function(ply)
    return "Test Kill Task 3 Description"
end

if SERVER then
    TASK.CanAssignTask = function(ply)
        return true
    end

    TASK.OnTaskAssigned = function(ply)
        ply:QueueMessage(MSG_PRINTBOTH, "Task Assigned: " .. TASK.Name(ply))
    end

    TASK.OnTaskRemoved = function(ply)
        ply:QueueMessage(MSG_PRINTBOTH, "Task Removed: " .. TASK.Name(ply))
    end

    TASK.OnTaskComplete = function(ply)
        ply:QueueMessage(MSG_PRINTBOTH, "Task Completed: " .. TASK.Name(ply))
    end
end

TASKMASTER.RegisterTask(TASK)