-module(epc_sgw_worker).
-behaviour(gen_server).

-export([init/1,handle_info/2]).
-export([start_link/1]).
-define(NAME,?MODULE).
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

handle_info(timeout,State)->
    {ok,Sock}=gen_tcp:accept(State#state.socket),
    {ok,Pid}=epc_sgw_worker_sup:start_child(State#state.socket),
    epc_sgw_server:registerChild(Pid),
    Ref=update_global_registry(),
    {noreply,State#state{socket=Sock,ref=Ref}};

handle_info({tcp,Socket,Message},State)->
    {noreply,State}.
    

update_global_registry()->
     Uid=fetch_user_data(),
     Ref=make_ref(),
     epc_sgw_registry:update_session({Uid,Ref,self()}),
     Ref.


fetch_user_data()->
        Uid=receive 
        {id,U}->U;
            _ -> exit(normal)
        end,
        Uid.