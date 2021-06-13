-module(mme_main_sup).
-behaviour(supervisor).
-export([start/1,stop/1,init/1]).


start(Args)->
    {ok,Pid}=supervisor:start_link({local,?MODULE}, ?MODULE, Args),
    {ok,Pid}.




init(Args)->
    Strategy={one_for_all,2000,3},
    ChildSpec=[
        
    ],
    {ok,{Strategy,ChildSpec}}.