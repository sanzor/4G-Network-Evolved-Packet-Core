-module(epc_pgw).
-behaviour(application).
-export([start/2,stop/1]).


start(normal,[])->
    {ok,Pid}=epc_sgw_main_sup:start_link(),
    {ok,Pid}.

start({takeover,_OtherNode})->
    {ok,Pid}=epc_sgw_main_sup:start_link(),
    Pid.

stop(Reason)->ok.
