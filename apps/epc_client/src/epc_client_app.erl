-module(epc_client_app).
-behaviour(application).
-export([start/2,stop/1]).
-record(state,{
    socket,
    printerRef
}).
-define(DB(X),io:format("~p",[X])).


start(normal,[])->
    Pid=spawn(fun()->start()end),
    {ok,Pid}.
stop(_Reason)->ok.

start()->
    epc_mme_server:authorize(application:get_env(epc_client,userId)),
    ClientPid=start_client(),
    ClientPid.


start_client()->
    PrinterRef=start_logger_process(),
    Socket=make_socket_connection(),
    ClientPid=spawn(fun()->loop(#state{printerRef=PrinterRef,socket=Socket})end),
    register(cli,ClientPid),
    ClientPid.

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

    
    
start_logger_process()->
    {ok,Path}=application:get_env(epc_client,printerPath),
    {ok,Handle}=file:open(Path, [write]),
    Pid=spawn(fun()->
                    logger_loop(Handle)
              end),
   
    register(printer,Pid),
  
    Ref=erlang:monitor(process,whereis(printer)),
    Ref.

logger_loop(File)->
   
    receive
        Message -> io:format(File,"Received ~p",[Message]),
                   io:format("Received ~p",[Message]),
                   logger_loop(File)
    end.

handle_message(Message,_State)->
    printer ! Message.


make_socket_connection()->
    {ok,Socket}=gen_tcp:connect(element(2,application:get_env(epc_client,address)),
                                element(2,application:get_env(epc_client,connectPort)),
                                []),
    ?DB(socket_cl),
    Socket.

     
     
