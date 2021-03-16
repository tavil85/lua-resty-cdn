ngx.ctx.content_length = 0
ngx.ctx.fileisbig = false
if not ngx.is_subrequest and ngx.var.http_cdnmanage ~= "localcurl" and ngx.req.get_method() ~= "HEAD" and not ngx.var.http_range then
    local res = ngx.location.capture(ngx.var.uri,{ method = ngx.HTTP_HEAD })
    if res.status == 200 then
        ngx.ctx.content_length = res.header["Content-Length"]
    end
    if (ngx.ctx.content_length+0) > 1048576 then
        ngx.ctx.fileisbig = true
    end
end
