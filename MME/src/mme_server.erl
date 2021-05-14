-module(mme_server).
-behaviour(gen_server).
-export([start_link/1,init/1,handle_call/3,handle_cast/2,handle_info/2,terminate/2]).
-define(SERVER,?MODULE).

-record(state,{}).
%API
start_link(Args)->
    {ok,Pid}=gen_server:start_link({local,?SERVER}, ?MODULE, Args, []),
    {ok,Pid}.


init(Args)->
    {ok,#state{}}.


%Callbacks

handle_info(Args,State)->
    {ok,State}.

handle_cast(Message,State)->
    {noreply,State}.

handle_call(Message,From,State)->
    {reply,State,State}.