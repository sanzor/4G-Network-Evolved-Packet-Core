-module(epc_client_app).
-behaviour(application).
-export([start/2,stop/1]).
-record(state,{
    socket,
    printerRef
}).
-define(DB(X),io:format("~p",[X])).
-define(EN(Key,Config),proplists:get_value(Key, Config)).

start(normal,[])->
    Pid=spawn(fun()->start()end),
    {ok,Pid}.
stop(_Reason)->ok.

start()->
    ClientPid=start_client(),
    ClientPid.


start_client()->
    Config=application:get_all_env(),
    ClientPid=spawn(fun()-> start(Config)end),
    ClientPid ! {epc_client,verify,?EN(userId, Config)},
    register(cli,ClientPid),
    ClientPid.



  

start(Config)->
    {_Something,_UserId}=epc_mme_api:authorize({?EN(userId, Config),
                                                ?EN(username, Config),
                                                ?EN(phoneNumber, Config)}),
    Socket=gen_tcp:connect(?EN(address,Config),?EN(port,Config),[binary]),
    PrinterRef=start_logger_process(Config),
    loop(#state{printerRef=PrinterRef,socket=Socket}).


loop(State)->
   
    receive
        {epc_client,verify,Id}->
                Data=term_to_binary({verify,Id}),
                gen_tcp:send(State#state.socket,Data), 
                loop(State);
        {'DOWN',_Ref,process,_PrinterPID,Reason}->
               
                io:format("Printer is down, reason:[~p]",[Reason]),
                exit(normal);
        {tcp,Socket,Message} -> 
            handle_message(Message,State),
            loop(Socket);
        {tcp_closed,_Socket}->
            exit(socket_closed)
    end.

    
    
start_logger_process(Config)->
    
    
    Pid=spawn(fun()->
                    Path=?EN(printerPath,Config),
                    {ok,Handle}=file:open(Path, [write]),
                    logger_loop(Handle)
              end),
              erlang:is_process_alive(Pid),
    register(printer,Pid),
    
    Ref=erlang:monitor(process,whereis(printer)),
    Ref.

logger_loop(File)->
    receive
        Message -> ?
                   io:format(File,"Received ~p",[Message]),
                   io:format("Received ~p",[Message]),
                   logger_loop(File)
    end.

handle_message(Message,_State)->
    printer ! Message.




     
     
