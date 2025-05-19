defmodule Golex.Board do
  alias Golex.NodeManager

  def add_cells(alive_cells, new_cells),
    do:
      (alive_cells ++ new_cells)
      |> Enum.uniq()

  def remove_cells(alive_cells, kill_cells), do: alive_cells -- kill_cells

  @doc "Returns cells that should still live on the next generation"
  def keep_alive_tick(alive_cells) do
    alive_cells
    |> Enum.map(
      &Task.Supervisor.async(
        {Golex.TaskSupervisor, NodeManager.random_node()},
        Golex.Board,
        :keep_alive_or_nilify,
        [alive_cells, &1]
      )
    )
    |> Task.await_many()
    |> remove_nil_cells()
  end

  @doc "Returns new born cells on the next generation"
  def become_alive_tick(alive_cells) do
    Golex.Cell.dead_neighbours(alive_cells)
    |> Enum.map(
      &Task.Supervisor.async(
        {Golex.TaskSupervisor, NodeManager.random_node()},
        Golex.Board,
        :become_alive_or_nilify,
        [alive_cells, &1]
      )
    )
    |> Task.await_many()
    |> remove_nil_cells()
  end

  def keep_alive_or_nilify(alive_cells, cell) do
    if Golex.Cell.keep_alive?(alive_cells, cell), do: cell, else: nil
  end

  def become_alive_or_nilify(alive_cells, dead_cell) do
    if Golex.Cell.become_alive?(alive_cells, dead_cell), do: dead_cell, else: nil
  end

  defp remove_nil_cells(cells), do: cells |> Enum.filter(& &1)
end
