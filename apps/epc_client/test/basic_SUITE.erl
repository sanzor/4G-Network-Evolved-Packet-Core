-module(basic_SUITE).
-author("adriansan_93@yahoo.com").

-export([
        all/0,
        init_per_suite/1,
        end_per_suite/1,
        init_per_testcase/2,
        end_per_testcase/2]).


% Test case exports
-define(GET(Key,Dict),proplists:get_value(Key, Dict)).
-include_lib("common_test/include/ct.hrl").
-include_lib("stdlib/include/assert.hrl").



-export[can_connect_socket/1,can_authorize/1].

init_socket(Config)->
    {ok,Socket}=gen_tcp:connect(proplists:get_value(hostname, Config),
                                proplists:get_value(port, Config),
                                []),
    {ok,Socket}.

suite()->all().

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
     case application:which_applications() of 
        undefined -> application:start(epc_client);
        _Pid ->ok
     end,
    _Config.

end_per_testcase(_Case,_Config)->ok.


all()->
    [
        % can_authorize,
        can_connect_socket
    ].

can_connect_socket(Config)->
       Res=try init_socket(Config) of
        {ok,_Socket}-> ok 
        catch
            _Error:_Reason-> _Error
        end,
    ?assertEqual(ok,Res).

can_authorize(Config)->
    ?assertMatch(ok,epc_mme_api:authorize({?GET(userid,Config),
                           ?GET(username,Config),
                           ?GET(phone,Config)}) andalso ok).


                
                
              
            

