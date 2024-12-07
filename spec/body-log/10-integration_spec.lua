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
        paths = { "request/structured" },
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
        paths = { "request/text" },
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
        paths = { "response/structured" },
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
        paths = { "response/text" },
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

      describe("request", function()

        pending("logs request body", function()
          -- TODO: implement
          assert.logfile(logfile).has.no.line("[error]", true)
        end)

        pending("doesn't log response body", function()
          -- TODO: implement
        end)

      end)

      describe("response", function()

        pending("logs response body", function()
          -- TODO: implement
        end)

        pending("doesn't log request body", function()
          -- TODO: implement
        end)

      end)

    end)



    describe("text", function()

      describe("request", function()

        pending("logs request body", function()
          -- TODO: implement
        end)

        pending("doesn't log response body", function()
          -- TODO: implement
        end)

      end)

      describe("response", function()

        pending("logs response body", function()
          -- TODO: implement
        end)

        pending("doesn't log request body", function()
          -- TODO: implement
        end)

      end)

    end)


    -- describe("request", function()
    --   pending("logs request body", function()
    --     local r = client:get("/request", {
    --       headers = {
    --         host = "test1.com"
    --       }
    --     })
    --     -- validate that the request succeeded, response status 200
    --     assert.response(r).has.status(200)
    --     -- now check the request (as echoed by the mock backend) to have the header
    --     local header_value = assert.request(r).has.header("hello-world")
    --     -- validate the value of that header
    --     assert.equal("this is on a request", header_value)
    --   end)
    -- end)

  end)

end end
