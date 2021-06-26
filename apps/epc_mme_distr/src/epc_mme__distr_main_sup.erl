-module(epc_mme__distr_main_sup).
-behaviour(supervisor).
-export([start_link/0,init/1]).
-define(NAME,?MODULE).

start_link()->
    {ok,Pid}=supervisor:start_link({local,?NAME},?NAME,[]),
    {ok,Pid}.




init([])->
    Strategy={one_for_all,0,1},
    ChildSpec=[{
        epc_mme_server,
        {epc_mme_distr_server,start_link,[33]},
        permanent,
        brutal_kill,
        worker,
        [epc_mme_server]}
    ],
    {ok,{Strategy,ChildSpec}}.