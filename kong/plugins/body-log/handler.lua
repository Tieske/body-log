local plugin = {
  PRIORITY = 500, -- run before logging plugins
  VERSION = "0.1",
}



function plugin:access(conf)
  if conf.request then
    kong.log.set_serialize_value("request.body", kong.request.get_body())
  end
  if conf.response then
    kong.service.request.enable_buffering()
  end
end



function plugin:log(conf)
  if conf.response then
    kong.log.set_serialize_value("response.body", kong.service.response.get_body())
  end
end



return plugin
