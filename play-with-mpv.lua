local socket = require("socket")
local uri = require('uri')

-- Биндим порт
local server = assert(socket.bind("0.0.0.0", 7531))
server:settimeout(0) -- ВАЖНО: неблокирующий режим

function check_connections()
    local client = server:accept()
    if client then
        client:settimeout(0.1)
        local inline, err = client:receive()
        
        if inline then
            local tbl = {}
            for part in string.gmatch(inline, "[^ ]+") do
                table.insert(tbl, part)
            end

            -- Ваша логика обработки команд
            if tbl[2] then
                local addr = string.gsub(tbl[2], "?play_url=", " loadfile ", 1)
                local addr1 = string.gsub(addr, "/", " ", 1)
                local line = uri.decode(addr1)
                mp.command(line)
            end

            -- Ответ клиенту
            if tbl[1] == nil or tbl[1] == "" then
                local hostname = os.getenv('HOSTNAME') or "Unknown"
                client:send("Connected=" .. hostname .. "\n")
            else
                local argum = string.gsub(tbl[1], "GET", "mpv-version", 1)
                local arga = mp.get_property(argum)
                if arga == nil then
                    client:send(argum .. "=0 \n")
                else
                    client:send(argum .. "=" .. arga .. "\n")
                end
            end
        end
        client:close()
    end
end

-- Запускаем проверку каждые 0.05 сек (вместо вечного цикла while)
local timer = mp.add_periodic_timer(0.05, check_connections)

function cleanup()
    server:close()
end

mp.register_event("shutdown", cleanup)
