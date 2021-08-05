-module(epc_swg_session_cache).
-behaviour(gen_event).
-export([start_link/0,init/1,handle_event/2,handle_call/2]).
-define(NAME,?MODULE).

-record(session,{
    pid=not_set,
    ref=not_set,
    route
}).
-record(state,{
    dict
}).

start_link()->
    {ok,Pid}=gen_event:start_link({global,?NAME},[]),
    {ok,Pid}.

init(Args)->
    {ok,#state{dict=dict:new()}}.

% -- callbacks
handle_event({create_session,Uid},State)->
    NewDict=create_session(Uid,State#state.dict),
    {ok,State#state{dict=NewDict}};

handle_event({register_session,{Uid,Ref,Pid}},State=#state{dict=Dict})->
    NewDict=register_session({Uid,Ref,Pid}, Dict),
    {ok,State#state{dict=NewDict}}.

handle_call(Message,State)->
    {ok,rr,State}.

create_session(Uid,Dict)->
    create_option(dict:find(Uid,Dict),Uid,Dict).
create_option({ok,Value},Uid,Dict)->Dict;
create_option(error,Uid,Dict)->
    dict:store(Uid,#session{}, Dict).

register_session({Uid,Ref,Pid},Dict)->
    dict:update(Uid,fun(Old)->Old#session{ref=Ref,pid=Pid} end, Dict).



    



    
    