-module(epc_mme_db_server).
-behaviour(gen_server).
-export([saveUser/1,updateUser/1,updatePosition/1,getUser/1,getPosition/1]).
-export([start_link/1,init/1,handle_call/3,handle_cast/2,handle_info/2]).
-define(SERVER,?MODULE).

-record(state,{}).
-record(user,{id,name,number}).
-record(upos,{id,lat,lng}).
%API
start_link(Args)->
    {ok,Pid}=gen_server:start_link({local,?SERVER}, ?MODULE, Args, []),
    {ok,Pid}.


saveUser(UserData)->
    gen_server:cast(?SERVER,{create_user, UserData}).

updateUser(UserData)->
    gen_server:cast(?SERVER, {update_user,UserData}).
updatePosition(PositionData) ->
    gen_server:cast(?SERVER,{update_position,PositionData}). 

getUser(Id)->
    gen_server:call(?SERVER, {get_user,Id}).

getPosition(Id)->
    gen_server:call(?SERVER, {get_position,Id}).
init(_)->
    {ok,#state{}}.


%Callbacks

handle_info(Args,State)->
    {ok,State}.


handle_cast({create_user,{Id,Name,Number}},State)->
    epc_mme_db:writeUser(#user{id=Id,name=Name,number=Number}),
    {noreply,State};
handle_cast({update_user,{Id,Name,Number}},State)->
    epc_mme_db:update_table_option(users,#user{id=Id,name=Name,number=Number}),
    {noreply,State};

    %no create position
handle_cast({update_position,{Id,Lat,Lng}},State)->
    epc_mme_db:update_table_option(positions,#upos{id=Id,lat=Lat,lng=Lng}),
    {noreply,State}.

handle_call({get_user,Id},From,State)->
    Reply=epc_mme_db:getUser(Id),
    {reply,Reply,State};
handle_call({get_position,Id},From,State)->
    Reply=epc_mme_db:getPosition(Id),
    {reply,Reply,State};
handle_call(Message,From,State)->
    {reply,State,State}.

update_table_option(users,Record)->epc_mme_db:updateUser(Record);
update_table_option(positions,Record)->epc_mme_db:writePosition(Record).   