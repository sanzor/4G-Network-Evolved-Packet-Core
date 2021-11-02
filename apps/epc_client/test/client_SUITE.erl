-module(client_SUITE).
-author("adriansan_93@yahoo.com").

-export([
        all/0,
        init_per_suite/1,
        end_per_suite/1,
        init_per_testcase/2,
        end_per_testcase/2]).

-export([can_login/1]).

-define(GET(Key,Dict),proplists:get_value(Key, Dict)).
-include_lib("common_test/include/ct.hrl").
-include_lib("stdlib/include/assert.hrl").


init_per_suite(_Config)->
    [{port,8081},
    {hostname,"localhost"},
    {userid,33},
    {username,44},
    {number,"0726709009"},
    {targetNode,'adi@DESKTOP-GOMS8S8'}
    ].

end_per_suite(_Config)->
    ok.

init_per_testcase(_Case,_Config)->
     case proplists:lookup(epc_client, application:which_applications()) of
        none -> application:ensure_started(epc_client);
        _ -> application:stop(epc_client),
             application:ensure_started(epc_client)
     end,
    _Config.

end_per_testcase(_Case,_Config)->
    case proplists:lookup(epc_client, application:which_applications()) of
        none -> ok;
        _ -> application:stop(epc_client)
    end,
    ok.

suite()->all().
all()->
    [
        % can_authorize,
        can_login
    ].

can_login(Config)->
    {X,_Y}=epc_client_api:login(?GET(username,Config),{?GET(hostname,Config),?GET(port,Config)}),
    ?assertEqual(ok,X).
