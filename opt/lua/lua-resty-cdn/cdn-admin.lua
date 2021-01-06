ngx.header.content_type = "text/plain"
local args, err = ngx.req.get_uri_args(1)
for key,value in pairs(args) do
    if key == "purge" then
        if value == "all" then
            ngx.shared.cdn_temp:flush_all()
            ngx.shared.cdn_temp:flush_expired()
            ngx.shared.cdn_dict:flush_all()
            ngx.shared.cdn_dict:flush_expired()
            ngx.say("Hash Table Purged")
        else
            ngx.shared.cdn_dict:delete(ngx.md5(value))
            ngx.say(value .. " is Purged")
        end
    elseif key == "status" then
        local bodyhash1, flags1 = ngx.shared.cdn_temp:get(ngx.md5(value))
        local bodyhash2, flags2, stale = ngx.shared.cdn_dict:get_stale(ngx.md5(value))
        ngx.say(value .. " status:")
        ngx.print("Synchronization: ")
        if bodyhash2 then
            ngx.say("Synced")
        else
            ngx.say("Not Synced")
        end
        ngx.print("Current Operation: ")
        if bodyhash1 then
            ngx.say("Updating")
        else
            ngx.say("Nothing")
        end
        ngx.print("Is Up To Date: ")
        if stale == false then
            ngx.say("True")
        else
            ngx.say("False")
        end
        ngx.print("TTL: ")
        ngx.say(ngx.shared.cdn_dict:ttl(ngx.md5(value)))
    end
end
