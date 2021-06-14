-module(mme_server).
-behaviour(gen_server).
-export([start_link/1,init/1,handle_call/3,handle_cast/2,handle_info/2]).
-define(SERVER,?MODULE).

-record(state,{}).
-record(user,{id,name,number}).
-record(position,{id,lat,lng}).
%API
start_link(Args)->
    {ok,Pid}=gen_server:start_link({local,?SERVER}, ?MODULE, Args, []),
    {ok,Pid}.


init(Args)->
    {ok,#state{}}.


%Callbacks

handle_info(Args,State)->
    {ok,State}.

handle_cast({update,Table,Key},State)->
    case Table of 
        users -> db:updateUser(Key);
        positions-> db:updatePosition(Key)
    end,
    {noreply,State};

handle_cast({create,{Id,Name,Number}},State)->
    db:createUser(#user{id=Id,name=Name,number=Number}),
    {noreply,State}.
handle_cast({update_user,{Id,Name,Number}})->
    
handle_call(Message,From,State)->
    {reply,State,State}.