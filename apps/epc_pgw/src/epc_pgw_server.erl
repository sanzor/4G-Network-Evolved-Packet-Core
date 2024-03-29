-module(epc_pgw_server).
-behaviour(gen_server).
-export([start_link/0,registerChild/1]).
-export([init/1,handle_cast/2]).

-define(SERVER,?MODULE).
%%----API
-record(state,{
    cmap,
    sock,
    route
}).

%API

start_link()->
    gen_server:start_link({local,?SERVER}, ?MODULE, [], []).

registerChild(Pid)->
    gen_server:cast(?SERVER, {newpid,Pid}).
init(Route)->
    {ok,#state{route=Route},0}.


%callbacks

handle_info(timeout,State)->
    {ok,Port}=application:get_env(listenPort),
    {ok,LSock}=gen_tcp:listen(Port, [binary]),
    {ok,Pid}=epc_sgw_worker_sup:start_child(LSock),
    Dict=dict:store(erlang:monitor(process, Pid),Pid,dict:new()),
    {noreply,State#state{sock=LSock,cmap=Dict}};


handle_info({'Down',Ref,Pid,_,Reason},State)->
    erlang:demonitor(Ref),
    NewDict=dict:erase(Ref,State#state.cmap),
    {noreply,State#state{cmap=NewDict}}.

handle_cast({newpid,Pid},State)->
    Ref=erlang:monitor(process,Pid),
    {noreply,State#state{cmap=dict:store(Ref,Pid,State#state.cmap)}}.



handle_call({filter,Filter},_,State)->
    {reply,dict:filter(Filter,State#state.cmap),State}.