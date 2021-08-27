-module(epc_sgw_registry).
-behaviour(gen_server).

-export([start_link/0,init/1]).

-export([create_session/1,update_session/1,get_session/1]).

-export([handle_cast/2,handle_call/3]).

-define(NAME,?MODULE).
-define(TABLE,user_table).
-record(session,{
    pid=not_set,
    ref=not_set,
    route
}).
-record(state,{
   table
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
    global:register_name(?NAME, Pid),
    {ok,Pid}.

init(Args)->
    {ok,#state{table=ets:new(?TABLE,[set,named_table])}}.


%%%%------------callbacks---------------------
%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


handle_cast({create_session,Uid},State)->
    ets_create_session(Uid),
    {noreply,State};

handle_cast({update_session,{Uid,Ref,Pid}},State)->
    Result=update_session({Uid,Ref,Pid}),
    {noreply,State}.

handle_call({get_session,Uid},From,State)->
    Result=get_session_option(Uid),
    {reply,Result,State}.


%%%%%-------------methods----------------------
ets_create_session(Uid)->
    create_option(ets:lookup(?TABLE,Uid),Uid).
create_option([{K,V}|Rest],_)->{ok,already_exists};
create_option([],Uid)->
    ets:insert(?TABLE,{Uid,#session{}}).

    
update_session({Uid,Ref,Pid})->
    dict:update(Uid,fun(Old)->Old#session{ref=Ref,pid=Pid} end, Dict).



get_session_option(Value)->get_option(dict:find(Value,Dict)).
get_option(_)->{not_found,node()};
get_option({ok,Value})->{found,node(),Value}.




    



    
    