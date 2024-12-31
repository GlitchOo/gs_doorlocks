DatabaseReady = false

CreateThread(function()
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `gs_doorlocks` (
            `doorid` int(11) NOT NULL AUTO_INCREMENT,
            `name` varchar(50) NOT NULL DEFAULT 'door',
            `data` longtext NOT NULL DEFAULT '[]',
            `lastupdate` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
            PRIMARY KEY (`doorid`)
        ) ENGINE=InnoDB AUTO_INCREMENT=0;
    ]])

    local doors = MySQL.query.await('SELECT * FROM `gs_doorlocks`')

    for i = 1, #doors do
        local row = doors[i]
        local data = json.decode(row.data)
        Doors[row.doorid] = InitDoor(row.doorid, data)
    end

    DatabaseReady = true
end)