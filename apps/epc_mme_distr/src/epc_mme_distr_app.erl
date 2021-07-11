-module(epc_mme_distr_app).
-behaviour(application).
-export([start/2,stop/1]).

-record(position,{
    id,
    lat,
    lng
}).

-record(user,{
    id,
    name,
    number
}).
create_database()->
    case mnesia:create_table(users,[{ram_copies,[node()]},
                               {disc_only_copies,nodes()},
                               {attributes,record_info(fields,user)},
                               {record_name,user}]) of
                                {atomic,ok} ->ok;
                                {already_exists,Table}->io:format("Table ~p exists",[Table]);
                                {aborted,Reason}->io:format("\nCould not create table  ~p exists ",[Reason])
                               end,
    case mnesia:create_table(positions,[{attributes,record_info(fields,position)},
                                   {ram_copies,[node()]},
                                   {disc_only_copies,nodes()},
                                   {record_name,position}]) of
                                {atomic,ok} ->ok;
                                {already_exists,T}->io:format("Table ~p exists",[T]);
                                {aborted,R}->io:format("\nCould not create table  ~p exists ",[R])
                                   end.



      
install()->
    mnesia:create_schema([node()]),
    application:start(mnesia),
    create_database().



start(normal,[])->
    install(),
    {ok,Pid}=epc_mme_distr_main_sup:start_link(),
    
    {ok,Pid}.

start({takeover,_OtherNode})->
    {ok,Pid}=epc_mme_distr_main_sup:start_link(),
    Pid.

stop(Reason)->ok.
