local value , flags , stale = ngx.shared.cdn_dict:get_stale(ngx.md5(ngx.var.uri))
if value and not stale and not ngx.is_subrequest and ngx.var.http_cdnmanage ~= "localcurl" and not ngx.var.http_range then
    return ngx.redirect(ngx.var.cdn_cloud_url .. ngx.var.uri)
end
