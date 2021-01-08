if ngx.status == 200 and ngx.req.get_method() ~= "HEAD" and not ngx.ctx.sync_lock then
    local file = io.open( ngx.ctx.filepath , "r")
    local size = file:seek("end")
    io.close(file)
    if size ~= ngx.ctx.content_length and string.lower(ngx.var.cdn_complete_interrupted_downloads) == "true" then -- complete interrupted download
        local curl_command = "curl -ks --resolve " .. ngx.var.host .. ":" .. ngx.var.server_port .. ":127.0.0.1 " .. ngx.var.scheme .. "://" .. ngx.var.host .. ":" .. ngx.var.server_port .. ngx.var.request_uri .. " --output " .. ngx.ctx.filepath
        if os.execute(curl_command) then
            size = ngx.ctx.content_length
        end
    end
    if size == ngx.ctx.content_length then -- check if the response body size matches content-length
        -- do cdn stuff
        local s3cmd_command = "s3cmd --access_key='" .. ngx.var.cdn_access_key .. "' --secret_key='" .. ngx.var.cdn_secret_key .. "' --host='" .. ngx.var.cdn_host .. "' --host-bucket='" .. ngx.var.cdn_host_bucket .. "' -P sync " .. ngx.ctx.filepath .. " " .. "s3://" .. ngx.var.cdn_bucket .. ngx.var.uri
        os.execute(s3cmd_command)
        ngx.shared.cdn_dict:set(ngx.md5(ngx.var.uri),ngx.md5(ngx.var.uri),(ngx.var.cdn_valid_time+0)) -- update hash table
    end
    os.remove(ngx.ctx.filepath) -- remove file
    ngx.shared.cdn_temp:delete(ngx.md5(ngx.var.uri)) -- remove update lock
end
