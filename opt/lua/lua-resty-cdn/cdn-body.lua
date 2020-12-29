if not ngx.ctx.sync_lock then -- check update lock
    -- save the response chunks to a variable
    ngx.ctx.temp_file = ngx.ctx.temp_file .. ngx.arg[1]
end
