local PLUGIN_NAME = "body-log"


-- helper function to validate data against a schema
local validate do
  local validate_entity = require("spec.helpers").validate_plugin_config_schema
  local plugin_schema = require("kong.plugins."..PLUGIN_NAME..".schema")

  function validate(data)
    return validate_entity(data, plugin_schema)
  end
end


describe(PLUGIN_NAME .. ": (schema)", function()


  it("sets proper defaults", function()
    local plugin, err = validate({})
    assert.is_nil(err)
    assert.are.same({
        request = false,
        response = false,
        structured = true,
      }, plugin.config)
  end)


  it("accepts proper configuration", function()
    local plugin, err = validate({
        request = true,
        response = true,
        structured = false,
      })

    assert.is_nil(err)
    assert.are.same({
        request = true,
        response = true,
        structured = false,
      }, plugin.config)
  end)

end)
