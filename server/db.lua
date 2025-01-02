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

    -- Remove empty doors
    MySQL.update.await('DELETE FROM `gs_doorlocks` WHERE data = \'[]\'')

    local doors = MySQL.query.await('SELECT * FROM `gs_doorlocks`')

    for i = 1, #doors do
        local row = doors[i]
        local data = json.decode(row.data)
        Doors[row.doorid] = InitDoor(row.doorid, data)
    end

    -- Import doors from config
    if Config.Doors and #Config.Doors > 0 then
        local transaction = {}

        for i = 1, #Config.Doors do
            local door = Config.Doors[i]
            local existingDoorId = nil
            
            -- Check to see if door exists
            if door.doors then
                for i = 1, 2 do
                    existingDoorId = DoorByHash(door.doors[i].hash)
                    if existingDoorId then break end
                end
            else
                existingDoorId = DoorByHash(door.door.hash)
            end

            if existingDoorId then
                -- Update existing door
                Doors[existingDoorId] = InitDoor(existingDoorId, door)
                -- Add to transaction table
                transaction[#transaction + 1] = {query = 'UPDATE `gs_doorlocks` SET `data` = ? WHERE `doorid` = ?', values = {json.encode(door), existingDoorId}}
            else
                -- Insert new door
                local insertId = MySQL.insert.await('INSERT INTO `gs_doorlocks` ( `name` ) VALUES ( ? )', { door.name })
                if insertId then
                    local newDoor = InitDoor(insertId, door)
                    Doors[insertId] = newDoor
                    MySQL.update('UPDATE gs_doorlocks SET data = ? WHERE doorid = ?', {json.encode(newDoor), insertId})
                end
            end
        end

        -- Update all doors in one transaction
        MySQL.transaction.await(transaction)
    end

    DatabaseReady = true

    print('^2[gs-doorlocks]^7 Database ready')

    TriggerEvent('gs-doorlocks:Ready')
end)