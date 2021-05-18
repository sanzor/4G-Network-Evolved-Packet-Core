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

install(Nodes)->
    ok=rpc:multicall(application, start, mnesia,[]),
    mnesia:create_schema(Nodes).

updatePosition(#position=Position)->
    undefined.

updateUser(#user=User)->undefined.

insert(#user=User)->undefined.
    