-module(epc_sgw_api).
-export([create_user_session/1,get_user_session/1]).


%%% Called by the epc_mme when creating the session
create_user_session(Args)->
    epc_sgw_registry:create_session(Args).

get_user_session(Uid)->
    epc_sgw_registry:get_session(Uid).
