-module(db).
-export([ install/1,
          getUser/1,createUser/1,updateUser/1,deleteUser/1,
          readPosition/1,updatePosition/1,deletePosition/1]).

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
    

update(Table,Record)->
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
        
createUser(Record=#user{id=Id})->
    case getUser(Id) of
        [] -> updateUser(Record);
        _ -> throw(io:format("User with ~p already exists",[Id]))
    end,
    update(users,Record).
updateUser(Record)->
    update(users,Record).
updatePosition(Record)->
    update(positions,Record).

readPosition(Id)->
    read(positions,Id).
deleteUser(Id)->
    delete(users,Id).

deletePosition(Id)->
    delete(positions,Id).

    