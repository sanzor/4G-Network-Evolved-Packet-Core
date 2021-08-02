-module(epc_mme_server).
-behaviour(supervisor).
-export([start_link/0,init/1]).
-export([updatePosition/1,authorize/1]).
-export([handle_cast/2,handle_call/3]).

-define(SERVER,?MODULE).
-record(state,{}).
-define(TIMEOUT,3000).
%API

start_link()->
    {ok,Pid}=gen_server:start_link({local,?SERVER}, ?MODULE, [], []),
    {ok,Pid}.



init(_)->
    {ok,#state{}}.

authorize(UserData)->
    gen_server:call(?SERVER, {authorize,UserData}, ?TIMEOUT).

updatePosition(UserPositionData)->
    gen_server:cast(?SERVER, {update_upos,UserPositionData}).

%callbacks
% 
% 
handle_cast({update_upos,UPos},State)->
    epc_mme_db_server:updatePosition(UPos),
    {noreply,State}.

handle_call({authorize,UserData},From,State)->
    Reply=[],
    {reply,Reply,State}.

