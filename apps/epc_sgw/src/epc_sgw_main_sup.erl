-module(epc_sgw_main_sup).
-behaviour(supervisor).
-export([start_link/0,init/1]).

-define(NAME,?MODULE).

start_link()->
    {ok,Pid}=supervisor:start_link({local,?NAME},?NAME , []),
    {ok,Pid}.

init([])->
    
    Strategy={one_for_all,0,1},
    ChildSpec=[
        {
            epc_sgw_registry,
            {epc_sgw_registry,start_link,[]},
            permanent,
            brutal_kill,
            worker,
            [epc_sgw_registry]
        },
        {
            epc_sgw_worker_sup,
            {epc_sgw_worker_sup,start_link,[]},
            permanent,
            brutal_kill,
            supervisor,
            [epc_sgw_main_sup] 
        },
        #{
            id=>epc_sgw_server,
            start=>{epc_sgw_server,start_link,[]},
            restart=>permanent,
            shutdown=>brutal_kill,
            type=>worker,
            mod=>[epc_sgw_server]
        }
    ],
    {ok,{Strategy,ChildSpec}}.
