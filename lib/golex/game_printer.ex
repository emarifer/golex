defmodule Golex.GamePrinter do
  @moduledoc """
  It is used to store a TRef, using `Agent`, as a timer reference
  to print the board to the standard output (STDOUT)
  at the specified interval.

  ## Examples
    iex> Golex.GamePrinter.start_printing_board
    :printing_started
    iex> Golex.GamePrinter.start_printing_board
    :already_printing
    iex> Golex.GamePrinter.stop_printing_board
    :printing_stopped
    iex> Golex.GamePrinter.stop_printing_board
    :already_stopped
  """
  use Agent

  alias Golex.{BoardServer, Console}

  @print_speed 1000

  def start_link(_opts) do
    Agent.start_link(fn -> nil end, name: __MODULE__)
  end

  def start_printing_board do
    Agent.get_and_update(__MODULE__, __MODULE__, :do_start_printing_board, [])
  end

  def do_start_printing_board(nil = _tref) do
    {:ok, tref} =
      :timer.apply_interval(
        @print_speed,
        __MODULE__,
        :print_board,
        []
      )

    {:printing_started, tref}
  end

  def do_start_printing_board(tref), do: {:already_printing, tref}

  def print_board do
    {alive_cells, generation_counter} = BoardServer.state()
    alive_counter = alive_cells |> Enum.count()

    Console.print(alive_cells, generation_counter, alive_counter)
  end

  def stop_printing_board do
    Agent.get_and_update(__MODULE__, __MODULE__, :do_stop_printing_board, [])
  end

  def do_stop_printing_board(nil = _tref), do: {:already_stopped, nil}

  def do_stop_printing_board(tref) do
    {:ok, :cancel} = :timer.cancel(tref)

    {:printing_stopped, nil}
  end
end
