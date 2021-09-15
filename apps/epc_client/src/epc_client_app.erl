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
    UserData=init_user_data(Config),
    {_Something,UserId}=epc_mme_api:authorize(UserData),
    {PrinterRef,Socket}=init_component_processes(Config),
   
    ClientPid=spawn(fun()->loop(#state{printerRef=PrinterRef,socket=Socket})end),
    ClientPid ! {epc_client,verify,UserId},
   
    register(cli,ClientPid),
    ClientPid.


init_user_data(Config)->
    ClientId=?EN(userId, Config),
    ClientName=?EN(username, Config),
    Phone=?EN(phoneNumber, Config),
   
    {ClientId,ClientName,Phone}.

init_component_processes(Config)->
    PrinterRef=start_logger_process(Config),
    Address=?EN(address,Config),
    Port=?EN(connectPort,Config),
    Socket=make_socket_connection(Address,Port),
    {PrinterRef,Socket}.
  
make_socket_connection(Address,Port)->
    {ok,Socket}=gen_tcp:connect(Address,Port,[binary]),
    
    Socket.

loop(State)->
   
    receive
        {epc_client,verify,Id}->
                
                Data=term_to_binary({verify,Id}),
               
                try gen_tcp:send(State#state.socket,Data) of
                    Something -> ?DB({received,Something})
                catch
                    Err:Reason->?DB({got_err,Err,Reason}),
                                ?DB(exiting),
                                exit(broken)
                end,
                receive 
                    Msg-> ?DB({received_on_socket,Msg})
                after 3000 ->
                    exit(did_not_respond_in_time)
                end,
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
    Path=?EN(printerPath,Config),
   
    {ok,Handle}=file:open(Path, [write]),
    
    
    Pid=spawn(fun()->
                    logger_loop(Handle)
              end),
              erlang:is_process_alive(Pid),
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




     
     
