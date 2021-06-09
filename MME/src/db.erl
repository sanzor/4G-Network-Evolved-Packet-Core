-module(db).
-export([updatePosition/1,updateUser/1,install/1]).

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
    


updatePosition(#position{}=Position)->
    mnesia:dirty_write(positions,Position).

updateUser(#user{}=User)->
    mnesia:dirty_write(users,User).


    