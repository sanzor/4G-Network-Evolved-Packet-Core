-module(epc_client_api).
-export([login/3,connect/2]).

login(UserId,UserName,PhoneNumber)->
    epc_client_server:login({UserId,UserName,PhoneNumber}).

connect(UserId,{Hostname,Port})->
    epc_client_server:connect(UserId,{Hostname,Port}).