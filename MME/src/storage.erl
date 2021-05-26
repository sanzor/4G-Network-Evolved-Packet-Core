-module(db).
-export([insert/2,update/2]).

-record(position,{
    id
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
    mnesia:create_table(positions,[{attributes,record_info(fields,position)},{record_name,position}]),

install(Nodes)->
    ok=rpc:multicall(Nodes,application, start, [mnesia]]),
    mnesia:create_schema(Nodes),
    create_database(),
    


updatePosition(#position=Position)->
    undefined.

updateUser(#user=User)->undefined.

insert(#user=User)->undefined.
    