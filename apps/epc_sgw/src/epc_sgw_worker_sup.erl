-module(epc_sgw_worker_sup).
-behaviour(supervisor).
-export([start_link/0,init/1,start_child/1]).

-define(NAME,?MODULE).
start_link()->
    {ok,Pid}=supervisor:start_link({local,?NAME},?NAME,[]),
    {ok,Pid}.


start_child(Socket)->
    supervisor:start_child(?NAME, [Socket]).
%---callbacks---------

init(_)->
    Strategy={simple_one_for_one,0,1},
    ChildSpec=[
        #{
            id=>epc_sgw_worker,
            start=>{epc_sgw_worker,start_link,[]},
            restart=>temporary,
            shutdown=>brutal_kill,
            mod=>[epc_sgw_worker],
            type=>worker
        }
    ],
    {ok,{Strategy,ChildSpec}}.