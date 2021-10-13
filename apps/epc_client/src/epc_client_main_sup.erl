-module(epc_client_main_sup).
-behaviour(supervisor).

-export([start_link/0,init/1]).

-define(NAME,?MODULE).
start_link()->
    {ok,Pid}=supervisor:start_link({local,?NAME},?MODULE,[]),
    {ok,Pid}.


init([])->
    Strategy={one_for_all,1,100},
    ChildSpec=[
        #{
            id=>epc_client_server,
            start=>{epc_client_server,start_link,[]},
            restart=>temporary,
            shutdown=>brutal_kill,
            mod=>[epc_client_server],
            type=>worker
        }
    ],
    {ok,{Strategy,ChildSpec}}.
    
