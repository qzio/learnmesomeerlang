-module(udpsrv).
-compile(export_all).


init(Port) ->
  spawn(?MODULE, server,[Port]).

server(Port) ->
  {ok, Socket} = gen_udp:open(Port,[binary]),
  listen(Socket).

listen(Socket) ->
  receive
    {udp, Socket, _Host, _Port, Bin} = Message ->
      io:format("server received:~p~n",[Message]),
      send_to_tcp_server(binary_to_list(Bin)),
      listen(Socket);
    terminate ->
      io:format("server: stopping");
    _ ->
      io:format("server received unknown thing"),
      listen(Socket)
  end.

send_to_tcp_server(Msg) when is_list(Msg) ->
  io:format("will try to send ~p to remotehost~n",[Msg]),
  RemoteHost = "localhost",
  {ok, Sock} = gen_tcp:connect(RemoteHost, 8080, [binary, {packet,0}]),
  SendResult = gen_tcp:send(Sock, [Msg]),
  io:format("send result from gen_tcp~p",[SendResult]),
  ok = gen_tcp:close(Sock);
send_to_tcp_server(M) ->
  io:format("send_to_tcp unknown param: ~p~n",[M]).

