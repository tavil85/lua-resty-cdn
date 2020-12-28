local value , flags =  ngx.shared.cdn_temp:get(ngx.md5(ngx.var.uri))
if not value then -- check update lock
    -- save the response chunks to a variable
    ngx.ctx.temp_file = ngx.ctx.temp_file .. ngx.arg[1]
end
