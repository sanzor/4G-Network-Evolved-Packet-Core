-module(epc_swg_session_cache).
-export([start/0,getSession/2]).


-record(session,{
    uid,
    pid=not_set,
    ref=not_set,
    route
}).

start()->
    {ok,dict:new()}.
    

getSession(Uid,Dict)->
    {ok,Record}=findUserData(Uid,Dict).


findUserData(Uid,Dict)->
    case dict:find(Uid,Dict) of
        {ok,Record}->Record;
        _-> throw("Undefined user")
    end.

    
    