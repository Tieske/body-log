local plugin = {
  PRIORITY = 500, -- run before logging plugins
  VERSION = "0.1",
}



function plugin:access(conf)
  if conf.request then
    local body
    if conf.structured then
      body = kong.request.get_body()
    end
    if not body then
      body = kong.request.get_raw_body()
    end
    if not body then
      body = "failed to retrieve body"
    end
    kong.log.set_serialize_value("request.body", body)
  end
  if conf.response then
    kong.service.request.enable_buffering()
  end
end



function plugin:log(conf)
  if conf.response then
    local body
    if conf.structured then
      body = kong.service.response.get_body()
    end
    if not body then
      body = kong.service.response.get_raw_body()
    end
    if not body then
      body = "failed to retrieve body"
    end
    kong.log.set_serialize_value("response.body", body)
  end
end



return plugin
