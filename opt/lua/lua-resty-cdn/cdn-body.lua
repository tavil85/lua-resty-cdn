if ngx.status == 200 and ngx.req.get_method() ~= "HEAD" and not ngx.ctx.fileisbig and (not ngx.ctx.sync_lock or (ngx.ctx.sync_lock == ngx.req.start_time())) and not ngx.var.http_range then
    ngx.shared.cdn_temp:set(ngx.md5(ngx.var.uri),ngx.req.start_time()) -- set update lock
    -- save the response chunks to a file
    ngx.ctx.filepath = "/var/cache/nginx/cdn_temp/" .. ngx.md5(ngx.var.uri)
    local file = io.open( ngx.ctx.filepath , "a")
    io.output(file)
    io.write(ngx.arg[1])
    io.close(file)
end
