-module(epc_mme_db).
-export([ 
          getUser/1,writeUser/1,updateUser/1,deleteUser/1,
          getPosition/1,writePosition/1,deletePosition/1]).

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
        _ ->  write(Table,Record)
    end.
writeUser(Record=#user{id=Id})->tryWrite(Record, fun(R)->getUser(R#user.id) end, users).
updateUser(Record=#user{id=Id})->tryUpdate(Record, fun(R)->getUser(R#user.id) end, users).
writePosition(Record=#position{id=Id})->tryWrite(Record, fun()->getPosition(Id) end, positions).

   


deleteUser(Id)->
    delete(users,Id).

deletePosition(Id)->
    delete(positions,Id).

    