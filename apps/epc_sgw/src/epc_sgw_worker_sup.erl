-module(epc_sgw_worker_sup).
-behaviour(supervisor).


-define(NAME,?MODULE).
start_link()->
    {ok,Pid}=supervisor:start_link({local,?NAME},?NAME,[]),
    {ok,Pid}.



%---callbacks---------
