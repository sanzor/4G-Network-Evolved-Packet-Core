-module(epc_mme_server).
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


init(_)->
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

handle_cast({create_user,{Id,Name,Number}},State)->
    epc_mme_db:writeUser(#user{id=Id,name=Name,number=Number}),
    {noreply,State};
handle_cast({update_user,{Id,Name,Number}},State)->
    epc_mme_db:updateUser(#user{id=Id,name=Name,number=Number}),
    {noreply,State};
handle_cast({update_position,{Id,Lat,Lng}},State)->
    epc_mme_db:writePosition(#position{id=Id,lat=Lat,lng=Lng}),
    {noreply,State}.

handle_call({get_user,Id},From,State)->
    Reply=epc_mme_db:getUser(Id),
    {reply,Reply,State};
handle_call({get_position,Id},From,State)->
    Reply=epc_mme_db:getPosition(Id),
    {reply,Reply,State};
handle_call(Message,From,State)->
    {reply,State,State}.