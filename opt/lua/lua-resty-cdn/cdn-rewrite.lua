local value , flags , stale = ngx.shared.cdn_dict:get_stale(ngx.md5(ngx.var.uri))
if value and not stale then
    return ngx.redirect(ngx.var.cdn_cloud_url .. ngx.var.uri);
end
