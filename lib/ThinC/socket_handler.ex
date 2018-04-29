defmodule ThinC.SocketHandler do
  @behaviour :cowboy_websocket_handler
  require Logger

  def init(_, _req, _opts) do
    {:upgrade, :protocol, :cowboy_websocket}
  end

  @timeout 6000000 # terminate if no activity for one minute

  #Called on websocket connection initialization.
  def websocket_init(_type, req, _opts) do
    Logger.info("init\n")
    Process.register(self(), :ws)
    state = %{}
    {:ok, req, state, @timeout}
  end

  # Handle 'ping' messages from the browser - reply
  def websocket_handle({:text, "ping"}, req, state) do
    Logger.info("got ping\n")
    {:reply, {:text, "pong"}, req, state}
  end

  # Handle other messages from the browser - don't reply
  def websocket_handle({:text, message}, req, state) do
    Logger.info("handle")
    IO.puts(message)
    {:ok, req, state}
  end

  # Format and forward elixir messages to client
  def websocket_info(message, req, state) do
    Logger.info("websocket info")
    {:reply, {:text, message}, req, state}
  end

  # No matter why we terminate, remove all of this pids subscriptions
  def websocket_terminate(_reason, _req, _state) do
    Logger.info("terminate")
    :ok
  end

end