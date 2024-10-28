local TASK = {}

TASK.id = "testmisctaskX"

TASK.Name = function(ply)
    return "Test Misc Task X"
end

TASK.Description = function(ply)
    return "Test Misc Task X Description"
end

if SERVER then
    TASK.CanAssignTask = function(ply)
        return false
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