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
    
-spec write(Table::atom(),term())->ok.
write(Table,Record)->
    mnesia:dirty_write(Table,Record).
-spec delete(Table::atom(),term())->ok.
delete(Table,Id)->
    mnesia:dirty_delete(Table,Id).

read(Table,Id)->
    mnesia:dirty_read(Table, Id).

-spec getUser(Id::term())->term().
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

writeUser(Record=#user{id=Id})->write(users,Record).
updateUser(Record=#user{id=Id})->write(users,Record).
writePosition(Record=#position{id=Id})->write(positions,Record).

   


deleteUser(Id)->
    delete(users,Id).

deletePosition(Id)->
    delete(positions,Id).

    