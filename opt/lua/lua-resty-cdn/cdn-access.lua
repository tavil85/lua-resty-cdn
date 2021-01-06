ngx.ctx.content_length = 0
if not ngx.is_subrequest then
    local res = ngx.location.capture(ngx.var.uri,{ method = ngx.HTTP_HEAD })
    if res.status == 200 then
        ngx.ctx.content_length = res.header["Content-Length"]
    end
end
