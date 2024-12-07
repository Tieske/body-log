local typedefs = require "kong.db.schema.typedefs"

local schema = {
  name = "body-log",
  fields = {
    { protocols = typedefs.protocols_http },
    { config = {
        -- The 'config' record is the custom part of the plugin schema
        type = "record",
        fields = {
          -- a standard defined field (typedef), with some customizations
          { request = { -- log request body?
              type = "boolean",
              required = true,
              default = false } },
          { response = { -- log response body?
              type = "boolean",
              required = true,
              default = false } },
          { structured = { -- log structured data as nested JSON? otherwise as (escaped) text
              type = "boolean",
              default = true,
              required = true } }
        },
      },
    },
  },
}

return schema
