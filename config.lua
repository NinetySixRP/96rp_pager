Config = {}

Config.Pager = {
    ["911p"] = {
        title = "Police",
        broadcastToJobs = {
            ["police"]=true,
        },
        broadcastToRoles = nil,
        discordPermissions = nil,
        jobPermissions = nil,
        webhooks = {
            ["a"]="<@9189297405006602> new pager received!"
        },
    },
    ["policeChat"] = {
        title = "Police",
        broadcastToJobs = {
            ["police"]=true,
        },
        broadcastToRoles = nil,
        discordPermissions = nil,
        jobPermissions = {
            "police"
        },
        webhooks = {
            ["a"]="<@9189297405006602> new pager received!"
        },
    },
    ["medicChat"] = {
        title = "Medic",
        broadcastToJobs = {
            ["ambulance"]=true,
        },
        broadcastToRoles = nil,
        discordPermissions = nil,
        jobPermissions = {
            "ambulance"
        },
        webhooks = {
            ["a"]="<@9189297405006602> new pager received!"
        },
    },
    ["911m"] = {
        title = "Medic",
        broadcastToJobs = {
            ["ambulance"]=true,
        },
        broadcastToRoles = nil,
        discordPermissions = nil,
        jobPermissions = nil,
        webhooks = {
            ["a"]="<@9189297405006602> new pager received!"
        },
    }
};

Config.Animation = {
    dict = 'anim@amb@business@bgen@bgen_no_work@',
    name = 'stand_phone_phoneputdown_wakeup_phone01',
    flag = 0
}

Config.LogWebhook = "";

-- Ingame limit: 63 characters