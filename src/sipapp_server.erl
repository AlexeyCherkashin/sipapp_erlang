-module(sipapp_server).

-export([sip_get_user_pass/4, sip_authorize/3, sip_route/5]).
-export([srv_init/2, srv_handle_call/3]).

-include_lib("nkserver/include/nkserver_module.hrl").

%expecting user with "niksip" domain, else you will not get the pass (default for all nksip is 1234)
sip_get_user_pass(_User, <<"nksip">>, _Req, _Call) ->
    <<"1234">>;
sip_get_user_pass(_User, _Realm, _Req, _Call) -> 
    false.

%check in case if it's shoulbe be authorized request
sip_authorize(AuthList, _Req, _Call) ->
    case lists:member(dialog, AuthList) orelse lists:member(register, AuthList) of
        true -> 
            ok;
        false ->
            case proplists:get_value({digest, <<"nksip">>}, AuthList) of
                true -> 
                    ok;            %password is valid
                false -> 
                    forbidden;     %user has failed authentication
                undefined -> 
                    {proxy_authenticate, <<"nksip">>}
                    
            end
    end.
    %routing the request. If has no User - proces "as is"
    %else if registered then check proxy
    sip_route(_Scheme, <<>>, <<"nksip">>, _Req, _Call) ->
        process;
    sip_route(Scheme, User, <<"nksip">>, _Req, _Call) ->
        UriList = nksip_registrar:find(?MODULE, Scheme, User, <<"nksip">>),
        {proxy, UriList, [record_route]};
    %in case if domain is not "nksip"
    sip_route(_Scheme, _User, _Domain, Req, _Call) ->
        case nksip_request:is_local_ruri(Req) of
            true ->
                process;
            false ->
                proxy
        end.
    
    
    %%Service initialization.
    srv_init(_Service, State) ->
        nkserver:put(?MODULE, started, httpd_util:rfc1123_date()),
        {ok, State}.
    
    
    %%Synchronous user call.
    srv_handle_call(get_started, _From, #{started:=Started}=State) ->
        {reply, {ok, Started}, State}.