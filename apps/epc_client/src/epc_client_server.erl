-module(epc_client_server).
-behaviour(gen_statem).
-export([call/1,cast/1  ,start_link/0]).
-export([handle_call/3,handle_info/2,handle_cast/2,init/1]).

-record(state,{}).
-define(NAME,?MODULE).
% api

start_link()->
    gen_statem:start_link({local,?NAME},?MODULE, [],[]).

cast(Command)->
    gen_statem:cast({local,?NAME}, Command).

call(Command)->
    gen_statem:call({local,?MODULE},{command,Command}).


% handlers

init([])->
    {ok,#state{}}.


handle_call()



