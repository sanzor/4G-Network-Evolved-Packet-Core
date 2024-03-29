-module(epc_pgw_worker).
-behaviour(gen_server).

-export([init/1,handle_cast/2,handle_call/3,handle_info/2]).
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
    {ok,Pid}=epc_pgw_worker_sup:start_child(State#state.socket),
    epc_pgw_server:registerChild(Pid),
    {noreply,State#state{socket=Sock}}.

handle_cast(Request,State)->
    {noreply,State}.

handle_call(Message,From,State)->
    {reply,State,State}.