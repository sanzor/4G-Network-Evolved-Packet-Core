-module(epc_client_server).
-behaviour(gen_statem).
-export([login/1,quit/0,connect/1,start_link/0]).
-export([handle_call/3,handle_info/2,handle_cast/2,init/1]).

-record(state,{
    userId,
    userName,
    phone
}).
-define(NAME,?MODULE).
% api

start_link()->
    gen_statem:start_link({local,?NAME},?MODULE, [],[]).

login(Data)->
    gen_statem:call({local,?NAME}, Data).

quit()->
    gen_statem:cast({local,?NAME},quit).

connect(UserId)->
    gen_statem:call({local,?MODULE},{connect,UserId}).


% handlers
callback_mode()->state_functions.
init([])->
    {ok,logged_out,#state{}}.


logged_out({call,_From},{quit,_},_State)->
    {stop,_State};
logged_out({call,_From},{login,{UserId,Username,PhoneNumber}},State)->
    Return= try 
    {_Something,_UserId}=epc_mme_api:authorize({UserId,Username,PhoneNumber}),
    {next_state,logged_in_not_verified,State#state{userId=UserId,userName=Username,phone=PhoneNumber}}
    catch
        _:_ -> {keep_state,logged_out,State}
    end,
    Return.

logged_in_not_verified(_,_,State#state{userId=UserId})->
    {_Something,_UserId}=epc_mme_api:authorize({UserId,Username,PhoneNumber}),
    {ok,Socket}=gen_tcp:connect(Address, Port, Opts)





