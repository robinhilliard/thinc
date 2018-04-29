defmodule ThinC.Server do
  use Application

  def start(_type, _args) do
    # All we do is handle websocket connections
    dispatch = :cowboy_router.compile([
      {:_,
        [
          {"/", SUI.SocketHandler, []}
        ]
      }
    ])

    # Cowboy supervises connection handler processes for us
    # All broking work happens inside these processes
    {:ok, _} = :cowboy.start_http(
      :http,
      100,
      [{:port, 8000}],
      [{:env, [{:dispatch, dispatch}]}]
    )
  end

end