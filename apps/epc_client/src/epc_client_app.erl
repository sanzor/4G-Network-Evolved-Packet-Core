-module(epc_client_app).
-behaviour(application).
-export([start/2,stop/1]).
-record(state,{
    socket,
    printerRef
}).



start(normal,[])->
     Pid=spawn(fun()->start()end),
    {ok,Pid}.
stop(Reason)->ok.
start()->
    epc_mme_server:authorize(application:get_env(epc_client,userId)),
    ClientPid=start_client(),
    ClientPid.

logger_loop(File)->
    receive
        Message -> io:format(File,"Received ~p",[Message]),
                   io:format("Received ~p",[Message]),
                   logger_loop(File)
    end.

loop(State)->
    receive
        {tcp,v,Id}->
                Data=term_to_binary({verify,Id}),
                gen_tcp:send(State#state.socket,Data,Data),
                loop(State);
        {'DOWN',_Ref,process,_PrinterPID,Reason}->
                io:format("Printer is down, reason:[~p]",[Reason]),
                exit(normal);
        {tcp,Socket,Message} -> 
            handle_message(Message,State),
            loop(Socket);
        {tcp_closed,_Socket}->exit(socket_closed)
    end.

start_client()->
    Socket=make_socket_connection(),
    PrinterRef=start_logger_process(),
    ClientPid=spawn(fun()->loop(#state{printerRef=PrinterRef,socket=Socket})end),
    register(cl,ClientPid),
    ClientPid.
    
    
start_logger_process()->
    {ok,Handle}=file:open(application:get_env(epc_client,printerPath), [write]),
    register(printer,spawn(fun()->logger_loop(Handle)end)),
    Ref=erlang:monitor(process,whereis(printer)),
    Ref.

handle_message(Message,_State)->
    printer ! Message.


make_socket_connection()->

    {ok,Socket}=gen_tcp:connect(
                               application:get_env(epc_client,connectPort),
                               application:get_env(epc_client,address),
                                []),
    Socket.

     
     
