-module(sipapp).
-export([launch/0, start_trace/0, stop_trace/0, loglevel/1]).



%%lazy mode, launch whole SIP app in one shot.
launch() ->
    %clean data for registar
    nksip_registrar:clear(sipapp_server),
    %trying to send OPTION from testclient2 and expecting 200
    {ok,200,[]} = nksip_uac:options(sipapp_testclient2, "<sip:127.0.0.1;transport=tls>", [{sip_pass, "1234"}]),
    %let's try REGISTER our testclient1 and testclient2 witch Contact header (get_meta for getting Contact from response)
    {ok,200,[{<<"contact">>, [<<"<sip:sipapp_testclient1@localhost:5070>", _/binary>>]}]} =
        nksip_uac:register(sipapp_testclient1, "sip:127.0.0.1", [{sip_pass, "1234"}, contact, {get_meta, [<<"contact">>]}]),
    %ignore headers
    {ok,200,[]} = nksip_uac:register(sipapp_testclient2, "sips:127.0.0.1", [{sip_pass, "1234"}, contact]),
    %include headers and ignore other information
    {ok,200,[{all_headers, _}]} = nksip_uac:register(sipapp_testclient2, "sips:127.0.0.1", [{sip_pass, "1234"}, {get_meta, [all_headers]}]),
%now let's try send OPTION after succesfull registration
    {ok,200,[]} = nksip_uac:options(sipapp_testclient1, "sip:127.0.0.1", []),
    {ok,200,[]} = nksip_uac:options(sipapp_testclient2, "sips:127.0.0.1", []),

    {ok,407,[]} = nksip_uac:options(sipapp_testclient1, "sips:sipapp_testclient2@nksip", [{route, "<sip:127.0.0.1;lr>"}]),
    {ok,200,[{<<"x-nk-id">>, [<<"sipapp_testclient2">>]}]} =
        nksip_uac:options(sipapp_testclient1, "sips:sipapp_testclient2@nksip",
                          [{route, "<sip:127.0.0.1;lr>"}, {sip_pass, "1234"},
                           {get_meta, [<<"x-nk-id">>]}]),
    %trying INVITE
    {ok,488,[]} = 
        nksip_uac:invite(sipapp_testclient2, "sip:sipapp_testclient1@nksip", [{route, "<sips:127.0.0.1;lr>"}]),

    {ok,200,[{dialog, DlgId}]}= 
        nksip_uac:invite(sipapp_testclient2, "sip:sipapp_testclient1@nksip",
                        [{route, "<sips:127.0.0.1;lr>"}, {body, nksip_sdp:new()},
                          auto_2xx_ack]),

    {ok, confirmed} = nksip_dialog:get_meta(invite_status, DlgId),
    [_, _, _] = nksip_dialog:get_all_data(),
    timer:sleep(1000),
    %and BYE
    {ok,200,[]} = nksip_uac:bye(DlgId, []).



%% trace messages (start/stop) to the console 
start_trace() ->
    nksip_trace:start(sipapp_server),
    nksip_trace:start(sipapp_testclient1),
    nksip_trace:start(sipapp_testclient2).


stop_trace() ->
    nksip_trace:stop(sipapp_server),
    nksip_trace:stop(sipapp_testclient1),
    nksip_trace:stop(sipapp_testclient2).



%% log messages from the console.
-spec loglevel(debug|info|notice) -> 
    ok.

loglevel(debug) ->
    nklib_log:console_loglevel(debug),
    ok = nksip:update(sipapp_server, #{sip_debug=>[call]}),
    ok = nksip:update(sipapp_testclient1, #{sip_debug=>[call]}),
    ok = nksip:update(sipapp_testclient2, #{sip_debug=>[call]});

loglevel(Level) ->
    nklib_log:console_loglevel(Level),
    ok.