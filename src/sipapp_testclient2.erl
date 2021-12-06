-module(sipapp_testclient2).

-export([sip_invite/2, sip_options/2]).
%processing INVITE from other client, process body
sip_invite(Req, _Call) ->
    {ok, Body} = nksip_request:body(Req),
    case nksip_sdp:is_sdp(Body) of
        true ->
            {ok, ReqId} = nksip_request:get_handle(Req),
            Fun = fun() ->
                nksip_request:reply(ringing, ReqId),
                timer:sleep(2000),
                nksip_request:reply({answer, Body}, ReqId)
            end,
            spawn(Fun),
            noreply;
        false ->
            {reply, {not_acceptable, <<"Invalid SDP">>}}
    end.
    %processing OPTIONS from other client
    sip_options(Req, _Call) ->
        {ok, SrvId} = nksip_request:srv_id(Req),
        {reply, {ok, [{add, "x-nk-id", SrvId}, contact, allow, accept, supported]}}.