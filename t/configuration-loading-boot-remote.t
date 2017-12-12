use lib 't';
use Test::APIcast 'no_plan';

$ENV{TEST_NGINX_HTTP_CONFIG} = "$Test::APIcast::path/http.d/*.conf";

env_to_nginx(
    'TEST_NGINX_APICAST_PATH',
    'THREESCALE_PORTAL_ENDPOINT'
);

master_on();
run_tests();

__DATA__

=== TEST 1: boot load configuration from remote endpoint
should load that configuration and not fail
--- main_config
env THREESCALE_PORTAL_ENDPOINT=http://127.0.0.1:$TEST_NGINX_SERVER_PORT;
env APICAST_CONFIGURATION_LOADER=boot;
env THREESCALE_DEPLOYMENT_ENV=foobar;
env PATH;
--- http_config
  lua_package_path "$TEST_NGINX_LUA_PATH";
--- config
location = /t {
  content_by_lua_block {
    local loader = require('apicast.configuration_loader.remote_v2')
    ngx.say(assert(loader:call()))
  }
}

location = /admin/api/services.json {
    echo '{}';
}
--- request
GET /t
--- response_body
{"services":[],"oidc":[]}
--- exit_code: 200


=== TEST 2: lazy load configuration from remote endpoint
should load that configuration and not fail
--- main_config
env THREESCALE_PORTAL_ENDPOINT=http://127.0.0.1:$TEST_NGINX_SERVER_PORT;
env APICAST_CONFIGURATION_LOADER=lazy;
env THREESCALE_DEPLOYMENT_ENV=foobar;
env PATH;
--- http_config
  lua_package_path "$TEST_NGINX_LUA_PATH";
--- config
location = /t {
  content_by_lua_block {
    local loader = require('apicast.configuration_loader.remote_v2')
    ngx.say(assert(loader:call('localhost')))
  }
}

location = /admin/api/services.json {
    echo '{}';
}
--- request
GET /t
--- response_body
{"services":[],"oidc":[]}
--- exit_code: 200
