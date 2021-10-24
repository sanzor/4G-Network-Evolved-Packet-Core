-module(epc_client_server).
-behaviour(gen_statem).
-export([login/1,quit/0,connect/1,start_link/0]).
-export([init/1,handle_event/3,callback_mode/0]).
-export([logged_out/3,logged_in_not_verified/3,waiting_verification/3]).
-record(state,{
    userId,
    userName,
    phone,
    authorized=false,
    socket
}).
-define(NAME,?MODULE).
-define(VERIFY_CONNECT_TIMEOUT,5000).
% api

start_link()->
    gen_statem:start_link({local,?NAME},?MODULE, [],[]).

login(Data)->
    gen_statem:call(?NAME,{login,Data},3000).

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
    gen_statem:reply(?NAME,{ok,logged_in,UserId}),
    {next_state,logged_in_not_verified,State#state{userId=UserId,userName=Username,phone=PhoneNumber}}
    catch
        Error:Reason -> 
        gen_statem:reply(?NAME,{error,Error,Reason}),
        {keep_state,logged_out,State}
    end,
    Return.

% event that comes on user pressing connect (already logged in)
logged_in_not_verified({call,_From},{connect,Address,Port},State)->
    {ok,Socket}=gen_tcp:connect(Address,Port,[binary]),
    erlang:send_after(?VERIFY_CONNECT_TIMEOUT, self(), {send_after_message,verify_ack}),
    {next_state,waiting_verification,State#state{socket=Socket},[]}. % move to new state and check the timeout !

waiting_verification({call,_From},{tcp,_Socket,_Raw},State)->
    {keep_state,waiting_verification,State#state{authorized=true}}.

% event that comes triggered by erlang:send_after
% checks if client was verified
handle_event({call,_From},{send_after,verify_ack},State=#state{authorized=A})->
    NewState= if A=:=true -> connected ; true -> logged_in_not_verified end,
    {next_state,NewState,State};

handle_event({call,From},Msg,State)->
    gen_statem:reply(From,{unkown_msg,Msg}),
    {keep_state,State}.

    






