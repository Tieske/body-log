local helpers = require "spec.helpers"


local PLUGIN_NAME = "body-log"


for _, strategy in helpers.all_strategies() do if strategy ~= "cassandra" then
  describe(PLUGIN_NAME .. ": (access) [#" .. strategy .. "]", function()
    local client
    local logfile = "/tmp/file-log"

    lazy_setup(function()

      local bp = helpers.get_db_utils(strategy == "off" and "postgres" or strategy, nil, { PLUGIN_NAME })

      -- inject a global file-log plugin
      bp.plugins:insert {
        name     = "file-log",
        protocols = { "http" },
        config   = {
          path = logfile,
        },
      }


      local route1 = bp.routes:insert({
        paths = { "/request/structured" },
      })
      bp.plugins:insert {
        name = PLUGIN_NAME,
        route = { id = route1.id },
        config = {
          request = true,
          response = false,
          structured = true,
        },
      }


      local route2 = bp.routes:insert({
        paths = { "/request/text" },
      })
      bp.plugins:insert {
        name = PLUGIN_NAME,
        route = { id = route2.id },
        config = {
          request = true,
          response = false,
          structured = false,
        },
      }


      local route3 = bp.routes:insert({
        paths = { "/response/structured" },
      })
      bp.plugins:insert {
        name = PLUGIN_NAME,
        route = { id = route3.id },
        config = {
          request = false,
          response = true,
          structured = true,
        },
      }


      local route4 = bp.routes:insert({
        paths = { "/response/text" },
      })
      bp.plugins:insert {
        name = PLUGIN_NAME,
        route = { id = route4.id },
        config = {
          request = false,
          response = true,
          structured = false,
        },
      }


      -- start kong
      assert(helpers.start_kong({
        database   = strategy,
        nginx_conf = "spec/fixtures/custom_nginx.template",
        plugins = "bundled," .. PLUGIN_NAME,
        declarative_config = strategy == "off" and helpers.make_yaml_file() or nil,
      }))
    end)


    lazy_teardown(function()
      helpers.stop_kong(nil, true)
    end)


    before_each(function()
      client = helpers.proxy_client()
      helpers.clean_logfile(logfile)
    end)


    after_each(function()
      if client then client:close() end
    end)



    describe("structured", function()

      it("logs only request body", function()
        assert(client:post("/request/structured", {
          headers = {
            ["Content-Type"] = "application/json",
          },
          body = {
            hello = "world",
          },
        }))
        ngx.sleep(1)
        -- check request
        local file_content = require("pl.utils").readfile(logfile)
        local json = require("cjson").decode(file_content)
        assert.same("world", json.request.body.hello)
        -- check response
        assert.is_nil(json.response.body)
      end)



      it("logs only response body", function()
        assert(client:post("/response/structured", {
          headers = {
            ["Content-Type"] = "application/json",
          },
          body = {
            hello = "world",
          },
        }))
        ngx.sleep(1)
        -- check request
        local file_content = require("pl.utils").readfile(logfile)
        local json = require("cjson").decode(file_content)
        assert.is_nil(json.request.body)
        -- check response
        assert.same("world", json.response.body.post_data.params.hello)
      end)

    end)



    describe("text", function()

      it("logs only request body", function()
        assert(client:post("/request/text", {
          headers = {
            ["Content-Type"] = "application/json",
          },
          body = {
            hello = "world",
          },
        }))
        ngx.sleep(1)
        -- check request
        local file_content = require("pl.utils").readfile(logfile)
        local json = require("cjson").decode(file_content)
        assert.same('{"hello":"world"}', json.request.body)
        -- check response
        assert.is_nil(json.response.body)
      end)



      it("logs only response body", function()
        assert(client:post("/response/text", {
          headers = {
            ["Content-Type"] = "application/json",
          },
          body = {
            hello = "world",
          },
        }))
        ngx.sleep(1)
        -- check request
        local file_content = require("pl.utils").readfile(logfile)
        local json = require("cjson").decode(file_content)
        assert.is_nil(json.request.body)
        -- check response
        assert.is_string(json.response.body)
        assert.matches('{"hello":"world"}', json.response.body, nil, true)
      end)

    end)

  end)

end end
