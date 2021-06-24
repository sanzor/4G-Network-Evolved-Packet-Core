-module(mme_app).
-behaviour(application).
-export([start/2,stop/1]).


start(normal,[])->
    {ok,Pid}=mme_main_sup:start(),
    {ok,Pid}.

start({takeover,_OtherNode})->
    {ok,Pid}=mme_main_sup:start_link(),
    Pid.

stop(Reason)->ok.
