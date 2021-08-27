-module(epc_sgw_worker).
-behaviour(gen_server).

-export([init/1,handle_info/2,handle_call/3,terminate/2,handle_cast/2]).
-export([start_link/1]).
-define(NAME,?MODULE).
-define(MESSAGES,<<131,100,0,8,109,101,115,115,97,103,101,115>>).
-define(AUTH_TIMEOUT,5000).
-record(state,{
    socket,
    ref,
    messages=[]
    }).

    %%%% API
    %%% 
start_link(Lsock)->
    gen_server:start_link(?NAME,[Lsock],[]).


init([Lsock])->
    {ok,#state{socket=Lsock},0}.


%%%%%%%%%%%%%% callbacks %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% 
handle_call(Message,From,State)->
    {reply,State,State}.
handle_cast(Message,State)->
    {noreply,State}.
handle_info({tcp_closed,_},State)->
    {stop,socket_closed,State};

handle_info(timeout,State)->
    
    {ok,Sock}=gen_tcp:accept(State#state.socket),
    
    {ok,Pid}=epc_sgw_worker_sup:start_child(State#state.socket),
    try_update_registry(),
    Ref=try_update_registry(),
    {noreply,State#state{socket=Sock,ref=Ref}};


handle_info({tcp,Socket,?MESSAGES},State)->
    gen_tcp:send(Socket, term_to_binary(State#state.messages)),
    {noreply,State};

handle_info({tcp,Socket,Message},State)->
    gen_tcp:send(Socket,term_to_binary({can_not_process,Message})),
    {noreply,State};

handle_info({tcp,Socket,Message},State)->
    io:format("Into socket"),
    Reply=handle(Message, State),
    gen_tcp:send(State#state.socket,Reply),
    {noreply,State};

handle_info(Message, State)->
    io:format("Could not handle message,out of band : ~p",[Message]),
    {noreply,State}.
terminate(socket_closed,State)->
    io:format("Socket closed"),
    ok;
terminate(Reason,State)->
    io:format("terminating,reason:~p",[Reason]),
    ok.


try_update_registry()->
    try update_registry() of
         Ref -> Ref
    catch
         Error:Reason->exit({update_registry_fail,{Error,Reason}})
    end.
        
update_registry()->
    
     Uid=wait_user_data(),
     Ref=make_ref(),
     epc_sgw_registry:update_session({Uid,Ref,self()}),
     Ref.

handle(Message,State)->
    Reply=handle_message(Message,State),
    Raw=erlang:term_to_binary(Reply),
    Raw.

handle_message(<<"messages">>,State)->
    {ok,State#state.messages};

handle_message(<<"ref">>,State)->
    {ok,State#state.ref};

handle_message(Request,State)->
    {generic_reply,State}.

wait_user_data()->
        Uid=receive 
        {id,U}->U
        after ?AUTH_TIMEOUT ->
            throw(mme_timeout)
        end,
        Uid.