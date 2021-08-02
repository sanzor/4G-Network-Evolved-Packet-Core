-module(epc_mme_api).
-export([updatePosition/1]).



authorize(Id)->
    epc_mme_server:authorize(Id).

updatePosition({Id,Lat,Lng})->
    epc_mme_server:updatePosition({Id,Lat,Lng}).









