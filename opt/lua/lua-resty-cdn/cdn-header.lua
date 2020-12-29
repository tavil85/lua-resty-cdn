local value , flags =  ngx.shared.cdn_temp:get(ngx.md5(ngx.var.uri))
ngx.ctx.sync_lock = value
if ngx.ctx.sync_lock then -- check update lock
    ngx.header["cdn-status"] = "Still Synchronizing"
end
