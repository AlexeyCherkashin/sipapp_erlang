
-module(sipapp_app).

-behaviour(application).

-export([start/0, start/2, stop/1]).

-define(APP, sipapp).

%starting NKSIP
-spec start() ->
    ok | {error, Reason::term()}.

start() ->
    application:ensure_all_started(?APP).



%OTP callbacks, start & stop
start(_StartType, _StartArgs) ->
    sipapp_sup:start_link().

stop(_State) ->
    ok.

