[![Unix build](https://img.shields.io/github/actions/workflow/status/Tieske/kong-plugin-body-log/test.yml?branch=master&label=Test&logo=linux)](https://github.com/Tieske/kong-plugin-body-log/actions/workflows/test.yml)
[![Luacheck](https://github.com/Tieske/kong-plugin-body-log/workflows/Lint/badge.svg)](https://github.com/Tieske/kong-plugin-body-log/actions/workflows/lint.yml)

Kong plugin for request & response body logging
===============================================

This plugin will add the request and/or response body to the fields the log-serializer
will include. As such this plugin doesn't log by itself, it just adds content to the
existing serializer setup.

It is the 'plugin version' of [this article](https://support.konghq.com/support/s/article/How-to-add-Request-and-Response-payloads-to-the-logging-plugins)
explaining how to log bodies using the pre-functions plugin.

When to use this plugin over the pre-functions option?
In many cases the pre-functions plugin isn't allowed due to the Kong admins not
allowing to run arbitrary Lua code (even with the sandbox). In those cases this
plugin offers an alternative, at the cost of having to bundle a custom plugin.
This plugin also offers a cleaner configuration experience for users.

---

Configuration
=============

To use it configure this plugin, and also configure a standard log plugin that uses
the default Kong log serializer (eg. file-log, tcp-log, http-log, etc).

property | type | default | required | description
-|-|-|-|-
`request`| bool | `false` | yes | Should the request body be logged?
`respone`| bool | `false` | yes | Should the response body be logged?
`structured`| bool | `true` | yes | Structured data is logged as nested JSON, otherwise it will be logged as text.

Structured data means content-types handled by [PDK function `request.get_body`](https://docs.konghq.com/gateway/latest/plugin-development/pdk/kong.request/#kongrequestget_bodymimetype-max_args-max_allowed_file_size):

- `application/x-www-form-urlencoded`
- `application/json`
- `multipart/form-data`


---

Changelog
=========

#### release instructions

- update changelog below
- update version in `handler.lua`
- update the rockspec filename
- update the rockspec file contents to reflect the same version
- commit all changes as `release X.Y.Z`
- tag with `vX.Y.Z`
- run `pongo pack`
- test the generated rock file
- distribute the rock file

### 0.1.0, unreleased

- first version.

