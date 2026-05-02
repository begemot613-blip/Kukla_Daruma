
local socket  = require("socket")
local http = require "socket.http"
local ltn12 = require "ltn12"
local json = require "cjson"
local util = require "cjson.util"

local ip = "127.0.0.1"
local port = "8987"
local filter = '.mkv|.mp4|.avi|.mov|.webm|.wmv'
---------------------------------------------------------------------------------------------------------------------
function play_magnet() --( 1 
local wait = "30"
----------------------------------------------------------------------------------------------
local arg_2 = mp.get_property("filename")
---------------------------------------------------------------------
local link1, link2  = arg_2:match("(.*)=urn:(.*)")
------------------------------------------------------------------
if link1 == "magnet:?xt" then   --( 2
---------------------------------------------------------------------
local reqbody = "{post body}"
local respbody = {} -- for the response body
local result, respcode, respheaders, respstatus = http.request {
    method = "POST",
     url = ("http://"..ip..":"..port.."/add/magnet?uri="..arg_2.."&download=true&ignore_duplicate=true"),
    source = ltn12.source.string(reqbody),
    headers = {
        ["content-type"] = "text/plain",
        ["content-length"] = tostring(#reqbody)
    },
    sink = ltn12.sink.table(respbody)
}
respbody = table.concat(respbody)
-------------------------------------------------------------------------
 local t = json.decode(respbody)  local hash = t.info_hash

if link2 ~= nil then --( 3
------------------------------------------------------------------------------------     -----------------------------------------------
--local url_files = ("http://"..ip..":"..port.."/torrents/"..hash.."/files")
----------------------------------------------------------------------------------------
local url_status = ("http://"..ip..":"..port.."/torrents/"..hash.."/status")
local progress = 0
while  progress  == 0 do  socket.sleep(1)
wait = wait -1 if wait <= 0 then break end
mp.command("show-text ждём_progress_"..wait.."cek")
body, status_code, headers, status_line = http.request(url_status)
--local t = json.decode(body)   progress = t.progress  
local status, t = pcall(json.decode, body)
if status and t then progress = t.progress end
end
------------------------------------------------------------------------------------    ===============================================
--body, status_code, headers, status_line = http.request(url_files)
local pls = ("/tmp/torrest_pls_"..hash..".m3u")

--
local script_dir = mp.get_script_directory()
--
os.execute(script_dir.."/hash_to_pls.sh "..hash.." "..ip)
mp.command("loadfile "..pls)

end --) 3
    end   --) 2]
end  --)1

function cleanup() end

mp.add_hook("on_load", 50, play_magnet)

--mp.add_hook("on_unload", 10, cleanup) magnet:?xt

