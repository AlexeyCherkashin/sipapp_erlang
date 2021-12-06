-module(sipapp_sup).

-behaviour(supervisor).

-export([init/1, start_link/0]).

%supervisor configuration that we're use
start_link() ->
    ChildsSpec = [
nksip:get_sup_spec(sipapp_server, #{
    sip_local_host => "localhost",
    plugins => [nksip_registrar],
    sip_listen => "sip:all:5060, <sip:all:5061;transport=tls>"
}),
nksip:get_sup_spec(sipapp_testclient1, #{
    sip_local_host => "localhost",
    sip_from => "sip:sipapp_testclient1@nksip",
    plugins => [nksip_uac_auto_auth],
    sip_listen => "sip:127.0.0.1:5070, sips:127.0.0.1:5071"
}),
nksip:get_sup_spec(sipapp_testclient2, #{
    sip_local_host => "localhost",
    sip_from => "sips:sipapp_testclient2@nksip",
    plugins => [nksip_uac_auto_auth],
    sip_listen => "sip:all:5080, sips:all:5081"
})
],
supervisor:start_link({local, ?MODULE}, ?MODULE, {{one_for_one, 10, 60}, ChildsSpec}).



init(ChildsSpec) ->
    {ok, ChildsSpec}.

