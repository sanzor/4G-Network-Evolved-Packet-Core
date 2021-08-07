-module(epc_sgw_session_cache).
-behaviour(gen_server).

-export([start_link/0,init/1]).

-export([create_session/1,update_session/1,get_session/1]).

-export([handle_cast/2,handle_call/3]).

-define(NAME,?MODULE).

-record(session,{
    pid=not_set,
    ref=not_set,
    route
}).
-record(state,{
    dict
}).

%%%%--------------------------API-------------------------------
%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
 
create_session(Uid)->
    gen_server:cast({global,?NAME},{create_session,Uid}).

update_session({Uid,Ref,Pid})->
    gen_server:cast({global,?NAME},{update_session,{Uid,Ref,Pid}}).

get_session(Uid)->
    gen_server:call({global,?NAME},{get_session,Uid}).

start_link()->
    {ok,Pid}=gen_server:start_link({global,?NAME}, ?MODULE, [], []),
    {ok,Pid}.

init(Args)->
    {ok,#state{dict=dict:new()}}.


%%%%------------callbacks---------------------
%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


handle_cast({create_session,Uid},State)->
    NewDict=create_session(Uid,State#state.dict),
    {noreply,State#state{dict=NewDict}};

handle_cast({update_session,{Uid,Ref,Pid}},State=#state{dict=Dict})->
    NewDict=update_session({Uid,Ref,Pid}, Dict),
    {noreply,State#state{dict=NewDict}}.

handle_call({get_session,Uid},From,State)->
    Result=dict:find(Uid,State#state.dict),
    {reply,Result,State}.


%%%%%-------------methods----------------------
create_session(Uid,Dict)->
    create_option(dict:find(Uid,Dict),Uid,Dict).
create_option({ok,Value},Uid,Dict)->Dict;
create_option(error,Uid,Dict)->
    dict:store(Uid,#session{}, Dict).

update_session({Uid,Ref,Pid},Dict)->
    dict:update(Uid,fun(Old)->Old#session{ref=Ref,pid=Pid} end, Dict).



    



    
    