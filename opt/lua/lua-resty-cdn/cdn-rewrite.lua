local value , flags , stale = ngx.shared.cdn_dict:get_stale(ngx.md5(ngx.var.uri))
if value and not stale and not ngx.is_subrequest and ngx.var.http_cdnmanage ~= "localcurl" then
    return ngx.redirect(ngx.var.cdn_cloud_url .. ngx.var.uri)
end
if ngx.is_subrequest and ngx.req.get_method() == "PUT" then -- subrequest for big files
    local value , flags =  ngx.shared.cdn_temp:get(ngx.md5(ngx.var.uri))
    if not value then -- check update lock
        ngx.shared.cdn_temp:set(ngx.md5(ngx.var.uri),ngx.req.start_time()) -- set update lock
        local filepath = "/var/cache/nginx/cdn_temp/0" .. ngx.md5(ngx.var.uri) -- added 0 to md5 to avoid curl temp file overlap
        local curl_command = "curl -ks --header cdnmanage:localcurl --resolve " .. ngx.var.host .. ":" .. ngx.var.server_port .. ":127.0.0.1 " .. ngx.var.scheme .. "://" .. ngx.var.host .. ":" .. ngx.var.server_port .. ngx.var.request_uri .. " --output " .. filepath
        local s3cmd_command = "s3cmd --access_key='" .. ngx.var.cdn_access_key .. "' --secret_key='" .. ngx.var.cdn_secret_key .. "' --host='" .. ngx.var.cdn_host .. "' --host-bucket='" .. ngx.var.cdn_host_bucket .. "' -P sync " .. filepath .. " " .. "s3://" .. ngx.var.cdn_bucket .. ngx.var.uri
        local remove_command = "rm " .. filepath
        os.execute('bash /opt/lua/lua-resty-cdn/background.sh "' .. curl_command .. '" "' .. s3cmd_command .. '" "' .. remove_command .. '" &') -- send commands to bash script to be evaluated in the bacground
        ngx.shared.cdn_dict:set(ngx.md5(ngx.var.uri),"big",(ngx.var.cdn_valid_time+0)) -- update hash table
        ngx.shared.cdn_temp:delete(ngx.md5(ngx.var.uri)) -- remove update lock
    end
    ngx.status = ngx.HTTP_OK
    return ngx.exit(ngx.HTTP_NO_CONTENT)
end
