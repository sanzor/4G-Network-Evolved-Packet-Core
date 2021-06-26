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
    mnesia:create_table(users,[{attributes,record_info(fields,user)},{record_name,user}]),
    mnesia:create_table(positions,[{attributes,record_info(fields,position)},{record_name,position}]).

install(Nodes)->
    rpc:multicall(Nodes,application, start, [mnesia]),
    mnesia:create_schema(Nodes),
    create_database().
start(normal,[])->
    {ok,Pid}=epc_mme_main_sup:start_link(),
    epc_mme_db:install([node()]),
    {ok,Pid}.

start({takeover,_OtherNode})->
    {ok,Pid}=epc_mme_main_sup:start_link(),
    Pid.

stop(Reason)->ok.
