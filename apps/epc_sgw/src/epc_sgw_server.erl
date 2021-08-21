-module(epc_sgw_server).
-behaviour(gen_server).
-export([start_link/0,registerChild/1]).
-export([init/1,handle_cast/2,handle_info/2]).

-define(SERVER,?MODULE).
%%----API
-record(state,{
    sessions,
    sock
}).

%%%%%%%%%%%%%% API %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

start_link()->
    gen_server:start_link({local,?SERVER}, ?MODULE, [], []).


% called by workers 
registerChild(Pid)->
    gen_server:cast(?SERVER, {newpid,Pid}).
init(_)->
    {ok,#state{sessions=dict:new()},0}.


%%%%%%%%%%%%% Callbacks %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Initialization
handle_info(timeout,State=#state{sock=S})->
    Pid=startFirstChild(S),
    Dict=dict:store(erlang:monitor(process, Pid),Pid,dict:new()),
    {noreply,State#state{sessions=Dict}};


handle_info({'Down',Ref,process,_,Reason},State)->
    erlang:demonitor(Ref),
    NewDict=dict:erase(Ref,State#state.sessions),
    {noreply,State#state{sessions=NewDict}}.

handle_cast({newpid,Pid},State)->
    Ref=erlang:monitor(process,Pid),
    {noreply,State#state{sessions=dict:store(Ref,Pid,State#state.sessions)}}.



handle_call({filter,Filter},_,State)->
    {reply,dict:filter(Filter,State#state.sessions),State}.

startFirstChild(Socket)->
    {ok,Port}=application:get_env(listenPort),
    {ok,LSock}=gen_tcp:listen(Port, [binary]),
    {ok,Pid}=epc_sgw_worker_sup:start_child(LSock),
    Pid.
