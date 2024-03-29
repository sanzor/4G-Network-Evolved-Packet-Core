-module(epc_client_app).
-behaviour(application).
-export([start/2,stop/1]).
-record(state,{
    socket,
    spawner,
    printerRef
}).

-define(DB(X),io:format("~p~n",[X])).
-define(EN(Key,Config),proplists:get_value(Key, Config)).

start(normal,[])->
    {ok,Pid}=epc_client_main_sup:start_link(),
    {ok,Pid}.

stop(_Reason)->ok.

  


start_client_deprecated()->
    Config=application:get_all_env(),
    Pid=self(),
    ClientPid= spawn(fun()-> startC(Config,Pid) end),
   
    ClientPid ! {epc_client,verify,?EN(userId, Config)},
    receive
        _MSG->ok
    after 1500 ->
        exit(timeout_client)
    end,
    register(cli,ClientPid),
    ClientPid.

startC(Config,SpawnerPid)->
   
    {_Something,_UserId}=epc_mme_api:authorize({?EN(userId, Config),
                                                ?EN(username, Config),
                                                ?EN(phoneNumber, Config)}),
    {ok,Socket}=gen_tcp:connect(?EN(address,Config),?EN(connectPort,Config),[binary]),
   
    PrinterRef=start_logger_process(Config),
    loop(#state{printerRef=PrinterRef,socket=Socket,spawner=SpawnerPid}).


loop(State)->
    receive
        {command,Command}->gen_tcp:send(State#state.socket,term_to_binary(Command));
        {epc_client,verify,Id}->
                Data=term_to_binary({verify,Id}),
                gen_tcp:send(State#state.socket,Data),
                loop(State);
        {'DOWN',_Ref,process,_PrinterPID,Reason}->
                exit({normal,Reason});
        {tcp,_Socket,Raw} -> 
            Message=binary_to_term(Raw),
            NewState=handle_socket_message(Message,State),
            loop(NewState);
        {tcp_closed,_Socket}->
            exit(socket_closed);
        MSG->?DB(MSG),
             loop(State)
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

handle_socket_message(Message,_State)->
     _State#state.spawner ! Message,
    _State.




     
     
