defmodule Golex.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    init_alive_cells = []

    children = [
      # Starts a worker by calling: Golex.Worker.start_link(arg)
      # {Golex.Worker, arg}
      {Task.Supervisor, name: Golex.TaskSupervisor},
      {Golex.BoardServer, init_alive_cells},
      {Golex.GamePrinter, []}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Golex.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
