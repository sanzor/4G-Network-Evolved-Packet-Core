-module(epc_mme_api).
-export([authorize/1,updatePosition/1]).



authorize(UserData)->
    epc_mme_server:authorize(UserData).

updatePosition({UserId,Lat,Lng})->
    epc_mme_server:updatePosition({UserId,Lat,Lng}).









