-module(epc_mme_main_sup).
-behaviour(supervisor).
-export([start_link/0,init/1]).
-define(NAME,?MODULE).

start_link()->
    {ok,Pid}=supervisor:start_link({local,?NAME},?NAME,[]),
    {ok,Pid}.




init([])->
    Strategy={one_for_all,0,1},
    ChildSpec=[
        {
        epc_mme_db_server,
        {epc_mme_db_server,start_link,[33]},
        permanent,
        brutal_kill,
        worker,
        [epc_mme_db_server]},
        {
          epc_mme_server,
          {epc_mme_server,start_link,[]},
          permanent,
          3000,
          worker,
          [epc_mme_server]   
        }
    ],
    {ok,{Strategy,ChildSpec}}.