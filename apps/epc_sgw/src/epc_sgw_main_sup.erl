-module(epc_sgw_main_sup).
-behaviour(supervisor).
-export([start_link/0,init/1]).

-define(NAME,?MODULE).

start_link()->
    {ok,Pid}=supervisor:start_link({local,?NAME},?NAME , []),
    {ok,Pid}.

init([])->
    
    {ok,}
