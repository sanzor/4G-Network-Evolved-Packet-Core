-module(mme_main_sup).
-behaviour(supervisor).
-export([start/1,init/1]).


start(Args)->
    {ok,Pid}=supervisor:start_link({local,?MODULE}, ?MODULE, Args),
    {ok,Pid}.




init(Args)->
    Strategy={one_for_all,2000,3},
    ChildSpec=[
        mme_server,
        {mme_server,start_link,[]},
        permanent,
        2000,
        worker,
        [mme_server]
    ],
    {ok,{Strategy,ChildSpec}}.