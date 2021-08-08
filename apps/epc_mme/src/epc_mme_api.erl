-module(epc_mme_api).
-export([authorize/1,updatePosition/1]).



authorize(UserId)->
    epc_mme_server:authorize(UserId).

updatePosition({UserId,Lat,Lng})->
    epc_mme_server:updatePosition({UserId,Lat,Lng}).









