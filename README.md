sipapp
=====

Example of SIP implementation in Erlang. 

How to use:

   $ git clone this-repo
   
  $ cd sipapp_erlang
  
  $ make compile
  
  $ make sipapp

Use
-----
Lazy mode: run process of registration, INVITE, OPTIONS and BYE: 

    $ sipapp:launch().

Watch whole way of traces: 

    $ sipapp:start_trace().

Register new user: 

    $ nksip_uac:register(sipapp_testclient2, "sips:127.0.0.1", [{sip_pass, "1234"}, contact]).
    
Send OPTIONS:

    $ nksip_uac:options(sipapp_testclient2, "sips:127.0.0.1", []).
    
    $ nksip_uac:options(sipapp_testclient1, "sips:sipapp_testclient2@nksip",
                          [{route, "<sip:127.0.0.1;lr>"}, {sip_pass, "1234"},
                           {get_meta, [<<"x-nk-id">>]}]).
                           
Send INVITE

    $ nksip_uac:invite(sipapp_testclient2, "sip:sipapp_testclient1@nksip", [{route, "<sips:127.0.0.1;lr>"}]).
