-module(epc_sgw_registry).
-behaviour(gen_server).


% ------ exposed methods ---------------------------------------
% 
-export([start_link/0,init/1]).

-export([create_session/1,update_session/1,get_session/1]).

-export([handle_cast/2,handle_call/3]).

%--------definitions--------------------------------------------

-define(NAME,?MODULE).
-define(TABLE,user_table).
-record(session,{
    uid=not_set,
    pid=not_set,
    ref=not_set
}).
-record(state,{
   table
}).

%%%%--------------------------API-------------------------------
%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
create_session(Uid)->
    gen_server:call({global,?NAME},{create_session,Uid}).

update_session({Uid,Ref,Pid})->
    gen_server:cast({global,?NAME},{update_session,{Uid,Ref,Pid}}).

get_session(Uid)->
    gen_server:call({global,?NAME},{get_session,Uid}).

start_link()->
    {ok,Pid}=gen_server:start_link({global,?NAME}, ?MODULE, [], []),
    global:register_name(?NAME, Pid),
    {ok,Pid}.

init(Args)->
    {ok,#state{table=ets:new(?TABLE,[set,named_table,{keypos,#session.uid}])}}.


%%%%------------callbacks---------------------
%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

handle_call({create_session,Uid},From,State)->
    Reply=ets_create_session(Uid),
    {reply,Reply,State};

handle_call({get_session,Uid},From,State)->
    Value=get_session_option(Uid),
    {reply,Value,State}.

handle_cast({update_session,{Uid,Ref,Pid}},State)->
    ets_update_session({Uid,Ref,Pid}),
    {noreply,State}.


%%%%%-------------methods----------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ets_create_session(Uid)->
    case ets:insert_new(?TABLE, #session{uid=Uid}) of
        true -> {session_created,Uid};
        false -> {session_exists,Uid}
    end.
   
ets_update_session({Uid,Ref,Pid})->
    case ets:lookup(?TABLE, Uid) of
        [] -> throw(element_not_found);
        [_]->ets:insert(?TABLE,#session{uid=Uid,ref=Ref,pid=Pid})
    end.
    

get_session_option(Uid)->
    get_option(ets:lookup(?TABLE, Uid)).

get_option([{_,Value}|_])->{found,Value};
get_option([])->{not_found,[]}.




    



    
    