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
    end
end
