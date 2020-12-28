local value , flags =  ngx.shared.cdn_temp:get(ngx.md5(ngx.var.uri))
if value then -- check update lock
    ngx.header["cdn-status"] = "Still Synchronizing"
end
