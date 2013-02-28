-module(esyslog).

-behaviour(gen_server).

%% API
-export([start_link/0, syslog/4]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2,
         handle_info/2, terminate/2, code_change/3]).

-record(state, {
    socket :: inet:socket(),
    ip :: inet:ip_adress(),
    port :: inet:port_number()
}).

start_link() ->
    {ok, IP} = application:get_env(?MODULE, server),
    {ok, Port} = application:get_env(?MODULE, port),
    gen_server:start_link({local, ?MODULE}, ?MODULE, [IP, Port], []).

syslog(Who, Facility, Level, Message) ->
    gen_server:cast(?MODULE, {syslog, Who, Facility, Level, Message}).

init([IP, Port]) ->
    case gen_udp:open(0) of
        {ok, Socket} ->
            {ok, #state{socket = Socket, ip = IP, port = Port}};
        {error, Reason} ->
            error_logger:error_msg("Can't open socket: ~s~n",
                [inet:format_error(Reason)]),
            {error, Reason}
    end.

handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast({syslog, Who, Facility, Level, Message}, State) ->
    W = list_to_binary(atom_to_list(Who)),
    M = list_to_binary(Message),
    P = list_to_binary(integer_to_list(Facility bor Level)),
    Msg = <<"<", P/binary, "> ", W/binary, ": ", M/binary>>,
    gen_udp:send(State#state.socket, State#state.ip, State#state.port, Msg),
    {noreply, State}.

handle_info(_Msg, State) ->
    {noreply, State}.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

terminate(_Reason, State) ->
    gen_udp:close(State#state.socket).
