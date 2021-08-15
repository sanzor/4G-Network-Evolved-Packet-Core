-module(epc_sgw_api).
-export([create_session/1]).


%%% Called by the epc_mme when creating the session
create_session(Args)->
    epc_sgw_registry:create_session(Args).
