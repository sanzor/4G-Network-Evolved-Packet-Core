-module(mme_app).
-behaviour(application).
-export([start/2,stop/1]).


start({distributed},Args)->
    {ok,Pid}=mme_main_sup:start(Args),
    {ok,pid}.

stop(Reason)->ok.
