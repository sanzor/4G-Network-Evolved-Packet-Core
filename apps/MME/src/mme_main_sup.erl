-module(mme_main_sup).
-behaviour(supervisor).
-export([start_link/0,init/1]).
-define(NAME,?MODULE).

start_link()->
    {ok,Pid}=supervisor:start_link({local,?NAME},?NAME,[]),
    {ok,Pid}.




init([])->
    Strategy={one_for_all,0,1},
    ChildSpec=[
        mme_server,
        {mme_server,start_link,[]},
        permanent,
        brutal_kill,
        worker,
        [mme_server]
    ],
    {ok,{Strategy,ChildSpec}}.