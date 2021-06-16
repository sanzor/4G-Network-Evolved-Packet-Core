-module(db).
-export([install/1,
          getUser/1,getPosition/1,
          writeUser/1,deleteUser/1,
          readPosition/1,writePosition/1,deletePosition/1]).

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
    

write(Table,Record)->
    mnesia:dirty_write(Table,Record).
delete(Table,Id)->
    mnesia:dirty_delete(Table,Id).

read(Table,Id)->
    mnesia:dirty_read(Table, Id).

getUser(Id)->
    case read(users,Id) of
        [] -> undefined;
        User -> User
    end.

getPosition(Id)->
    case read(positions,Id) of
        [] -> undefined;
        Position ->Position
    end.


tryWrite(Record,Func,Table) when is_function(Func)->
    case Func(Record) of 
        [] -> write(Table,Record);
        _ -> throw(io:format("Record from table : ~p Already exists",[Table]))
    end.
tryUpdate(Record,Func,Table)->
    case Func(Record) of 
        [] -> throw(io:format("Record ~p table: does not exist",[Record]));
        _ ->  write(users,Record)
    end.
writeUser(Record=#user{id=Id})->tryWrite(Record, fun(Id)->getUser(Id) end, users).
writePosition(Record=#position{id=Id})->tryWrite(Record, fun(Id)->getPosition(Id) end, positions).
updateUser(Record=#user{id=Id})->
    case getUser(Id) of
        [] -> throw(io:format("User with ~p does not exist",[Id]));
        _ ->  write(users,Record)
    end.


deleteUser(Id)->
    delete(users,Id).

deletePosition(Id)->
    delete(positions,Id).

    