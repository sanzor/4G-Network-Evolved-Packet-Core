-module(epc_mme_app).
-behaviour(application).
-export([start/2,stop/1]).


start(normal,[])->
    {ok,Pid}=epc_mme_main_sup:start_link(),
    {ok,Pid}.

start({takeover,_OtherNode})->
    {ok,Pid}=epc_mme_main_sup:start_link(),
    Pid.

stop(Reason)->ok.
