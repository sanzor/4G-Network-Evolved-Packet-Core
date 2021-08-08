-module(epc_client_app).
-behaviour(application).
-export([start/1]).



start(normal,[])->
    {ok,Pid}=epc_mme_main_sup:start_link(),
    {ok,Pid}.

start({takeover,_OtherNode})->
    {ok,Pid}=epc_mme_main_sup:start_link(),
    Pid.

stop(Reason)->ok.



loop(Socket)->
    receive 
        {tcp,Message,Socket} -> 
            handle_message(Message,Socket),
            loop(Socket);
        {tcp_closed,_}->handle_close()
    end.


handle_close()->undefined.
handle_message(Message,Socket)->undefined.
connect()->
    {ok,UserId}=application:get_env(userid),
    epc_mme_api:authorize(UserId),
    Socket=make_connection(),
    loop(Socket).


make_connection()->
    {ok,PortNr}=application:get_env(port_nr),
    {ok,Address}=application:get_env(address),
    {ok,Socket}=gen_tcp:connect(Address, PortNr, []),
    Socket.

     
     
