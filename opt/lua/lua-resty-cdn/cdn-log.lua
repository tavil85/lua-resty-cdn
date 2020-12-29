if ngx.status == 200 and ngx.req.get_method() ~= "HEAD" and not ngx.ctx.sync_lock then
    if ngx.ctx.old_file == ngx.md5(ngx.ctx.temp_file) then -- check if the file changed
        ngx.shared.cdn_dict:expire(ngx.md5(ngx.var.uri),(ngx.var.cdn_valid_time+0))
    else
        ngx.shared.cdn_temp:set(ngx.md5(ngx.var.uri),ngx.md5(ngx.ctx.temp_file)) -- update lock
        -- save response to a file
        local filepath = "/var/cache/nginx/cdn_temp/" .. ngx.md5(ngx.var.uri)
        local file = io.open( filepath , "w")
        io.output(file)
        io.write(ngx.ctx.temp_file)
        io.close(file)
        -- do cdn stuff
        local s3cmd_command = "s3cmd --access_key='" .. ngx.var.cdn_access_key .. "' --secret_key='" .. ngx.var.cdn_secret_key .. "' --host='" .. ngx.var.cdn_host .. "' --host-bucket='" .. ngx.var.cdn_host_bucket .. "' -P sync " .. filepath .. " " .. "s3://" .. ngx.var.cdn_bucket .. ngx.var.uri
        os.execute(s3cmd_command)
        -- remove file
        os.remove(filepath)
        ngx.shared.cdn_temp:delete(ngx.md5(ngx.var.uri)) -- remove update lock
        ngx.shared.cdn_dict:set(ngx.md5(ngx.var.uri),ngx.md5(ngx.ctx.temp_file),(ngx.var.cdn_valid_time+0)) -- update hash table
    end
end
