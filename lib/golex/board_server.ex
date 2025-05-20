defmodule Golex.BoardServer do
  @moduledoc """
  Defines a public interface for the board server.

  ## Examples
    iex> Golex.BoardServer.start_game
    :game_started
    iex> Golex.BoardServer.start_game
    :game_already_running
    iex> Golex.BoardServer.stop_game
    :game_stoped
    iex> Golex.BoardServer.stop_game
    :game_not_running
    iex> Golex.BoardServer.change_speed(500)
    :game_started
    iex> Golex.BoardServer.stop_game
    :game_stoped

    iex> Golex.BoardServer.set_alive_cells([{0, 0}])
    [{0, 0}]
    iex> Golex.BoardServer.alive_cells
    [{0, 0}]
    iex> Golex.BoardServer.add_cells([{0, 1}])
    [{0, 0}, {0, 1}]
    iex> Golex.BoardServer.alive_cells
    [{0, 0}, {0, 1}]
    iex> Golex.BoardServer.state
    {[{0, 0}, {0, 1}], 0}

    iex> Golex.BoardServer.generation_counter
    0
    iex> Golex.BoardServer.tick
    :ok
    iex> Golex.BoardServer.generation_counter
    1
    iex> Golex.BoardServer.state
    {[], 1}
  """
  use GenServer

  require Logger

  alias Golex.{Board, NodeManager}

  @name {:global, __MODULE__}
  # speed in milliseconds ==>
  @game_speed 1000

  # Client

  def start_link(init_alive_cells) when is_list(init_alive_cells) do
    case GenServer.start_link(__MODULE__, init_alive_cells, name: @name) do
      {:ok, pid} ->
        Logger.info("Started #{__MODULE__} master")
        {:ok, pid}

      {:error, {:already_started, pid}} ->
        Logger.info("Started #{__MODULE__} slave")
        {:ok, pid}
    end
  end

  def alive_cells, do: GenServer.call(@name, :alive_cells)

  def generation_counter, do: GenServer.call(@name, :generation_counter)

  def state, do: GenServer.call(@name, :state)

  @doc """
  Clears board and adds only new cells.
  Generation counter is reset.
  """
  def set_alive_cells(cells) do
    GenServer.call(@name, {:set_alive_cells, cells})
  end

  def add_cells(cells), do: GenServer.call(@name, {:add_cells, cells})

  def tick, do: GenServer.cast(@name, :tick)

  def start_game(speed \\ @game_speed) do
    GenServer.call(@name, {:start_game, speed})
  end

  def stop_game, do: GenServer.call(@name, :stop_game)

  def change_speed(speed) do
    stop_game()

    start_game(speed)
  end

  # GenServer Callbacks

  @impl true
  def init(alive_cells) do
    Logger.info(
      "Started #{__MODULE__} with initial state equal to: #{inspect({alive_cells, nil, 0})}"
    )

    {:ok, {alive_cells, nil, 0}}
  end

  @impl true
  def handle_call(
        :alive_cells,
        _from,
        {alive_cells, _tref, _generation_counter} = state
      ) do
    {:reply, alive_cells, state}
  end

  @impl true
  def handle_call(
        :generation_counter,
        _from,
        {_alive_cells, _tref, generation_counter} = state
      ) do
    {:reply, generation_counter, state}
  end

  @impl true
  def handle_call(
        :state,
        _from,
        {alive_cells, _tref, generation_counter} = state
      ) do
    {:reply, {alive_cells, generation_counter}, state}
  end

  @impl true
  def handle_call(
        {:set_alive_cells, cells},
        _from,
        {_alive_cells, tref, _generation_counter} = _state
      ) do
    {:reply, cells, {cells, tref, 0}}
  end

  @impl true
  def handle_call(
        {:add_cells, cells},
        _from,
        {alive_cells, tref, generation_counter}
      ) do
    alive_cells = Board.add_cells(alive_cells, cells)

    {:reply, alive_cells, {alive_cells, tref, generation_counter}}
  end

  @impl true
  def handle_call(
        {:start_game, speed},
        _from,
        {alive_cells, nil = _tref, generation_counter}
      ) do
    {:ok, tref} = :timer.apply_interval(speed, __MODULE__, :tick, [])
    # ↑↑↑ See footnote ↑↑↑

    {:reply, :game_started, {alive_cells, tref, generation_counter}}
  end

  @impl true
  def handle_call(
        {:start_game, _speed},
        _from,
        {_alive_cells, _tref, _generation_counter} = state
      ) do
    {:reply, :game_already_running, state}
  end

  @impl true
  def handle_call(
        :stop_game,
        _from,
        {_alive_cells, nil = _tref, _generation_counter} = state
      ) do
    {:reply, :game_not_running, state}
  end

  @impl true
  def handle_call(
        :stop_game,
        _from,
        {alive_cells, tref, generation_counter}
      ) do
    {:ok, :cancel} = :timer.cancel(tref)
    # ↑↑↑ See footnote ↑↑↑

    {:reply, :game_stoped, {alive_cells, nil, generation_counter}}
  end

  @impl true
  def handle_cast(:tick, {alive_cells, tref, generation_counter}) do
    keep_alive_task =
      Task.Supervisor.async(
        {Golex.TaskSupervisor, NodeManager.random_node()},
        Board,
        :keep_alive_tick,
        [alive_cells]
      )

    become_alive_task =
      Task.Supervisor.async(
        {Golex.TaskSupervisor, NodeManager.random_node()},
        Board,
        :become_alive_tick,
        [alive_cells]
      )

    keep_alive_cells = Task.await(keep_alive_task)
    born_cells = Task.await(become_alive_task)

    alive_cells = keep_alive_cells ++ born_cells

    {:noreply, {alive_cells, tref, generation_counter + 1}}
  end
end

# REFERENCES:
# Different ways to register the GenServer name
# and call it from different nodes in Elixir:
# https://itnext.io/different-ways-to-register-genserver-name-in-elixir-e2708b84eed8

# FOOTNOTE:
# https://www.erlang.org/doc/apps/stdlib/timer.html#apply_interval/4
# https://www.erlang.org/doc/apps/stdlib/timer.html#cancel/1
#
# `apply_interval/4` is a function similar to JavaScript's `setInterval`:
# it executes a callback with the given interval.
# Given a reference (`TRef`), we can cancel its execution.
# It's similar to `clearInterval` in JavaScript.
