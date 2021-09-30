-module(epc_client_app).
-behaviour(application).
-export([start/2,stop/1]).
-record(state,{
    socket,
    spawner,
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
   
    ClientPid=spawn(fun()-> startC(Config,self())end),
    ClientPid ! {self(),{epc_client,verify,?EN(userId, Config)}},
    receive
        MSG->?DB({got_from_loop,MSG})
    after 1500 ->
        exit(timeout_client)
    end,
    register(cli,ClientPid),
    ClientPid.



  

startC(Config,SpawnerPid)->
    {_Something,_UserId}=epc_mme_api:authorize({?EN(userId, Config),
                                                ?EN(username, Config),
                                                ?EN(phoneNumber, Config)}),
    Socket=gen_tcp:connect(?EN(address,Config),?EN(port,Config),[binary]),
    PrinterRef=start_logger_process(Config),
    loop(#state{printerRef=PrinterRef,socket=Socket,spawner=SpawnerPid}).


loop(State=#state{spawner=From})->
    
    receive
        {From,{epc_client,verify,Id}}->
                Data=term_to_binary({verify,Id}),
                From ! {ok,verified,Id},
                gen_tcp:send(State#state.socket,Data),
                loop(State);
        {'DOWN',_Ref,process,_PrinterPID,Reason}->
                io:format("Printer is down, reason:[~p]",[Reason]),
                exit({normal,Reason});
        {tcp,Socket,Message} -> 
            handle_message(Message,State),
            loop(Socket);
        {tcp_closed,_Socket}->
            exit(socket_closed);
        MSG->?DB({unknown,MSG}),
             exit(unknown)
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
    ?DB(File),
    receive
        Message -> ?DB(File),
                   io:format(File,"Received ~p",[Message]),
                   io:format("Received ~p",[Message]),
                   logger_loop(File)
    end.

handle_message(Message,_State)->
    io:format("got message ~p",[binary_to_term(Message)]).




     
     
