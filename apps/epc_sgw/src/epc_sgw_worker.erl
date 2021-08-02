-module(epc_sgw_worker).
-behaviour(gen_server).

-export([init/1,handle_cast/2,handle_call/3,handle_info/2,terminate/2]).
-export([start_link/1]).
-define(NAME,?MODULE).
-record(state,{
    socket,
    messages=[]
    }).

start_link(Lsock)->
    gen_server:start_link(?NAME,[Lsock],[]).


init([Lsock])->
    {ok,#state{socket=Lsock},0}.


%callbacks

handle_info(timeout,State)->
    {ok,Sock}=gen_tcp:accept(State#state.socket),
    {ok,Pid}=epc_sgw_worker_sup:start_child(State#state.socket),
    epc_sgw_server:registerChild(Pid),
    {noreply,State#state{socket=Sock}}.

handle_info({tcp,Socket,Message},State)->
    
