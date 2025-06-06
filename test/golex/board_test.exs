defmodule Golex.BoardTest do
  use ExUnit.Case, async: true

  test "add new cells to alive cells without duplicates" do
    alive_cells = [{1, 1}, {2, 2}]
    new_cells = [{0, 0}, {1, 1}]

    actual_alive_cells =
      Golex.Board.add_cells(alive_cells, new_cells)
      |> Enum.sort()

    expected_alive_cells = [{0, 0}, {1, 1}, {2, 2}]

    assert actual_alive_cells == expected_alive_cells
  end

  test "remove cells which must be killed from alive cells" do
    alive_cells = [{1, 1}, {4, -2}, {2, 2}, {2, 1}]
    kill_cells = [{1, 1}, {2, 2}]

    actual_alive_cells = Golex.Board.remove_cells(alive_cells, kill_cells)
    expected_alive_cells = [{4, -2}, {2, 1}]

    assert actual_alive_cells == expected_alive_cells
  end

  test "alive cell with 2 neighbours lives on to the next generation" do
    alive_cells = [{0, 0}, {1, 0}, {2, 0}]
    expected_alive_cells = [{1, 0}]

    assert Golex.Board.keep_alive_tick(alive_cells) == expected_alive_cells
  end

  test "dead cell with three live neighbours becomes a live cell" do
    alive_cells = [{0, 0}, {1, 0}, {2, 0}, {1, 1}]
    born_cells = Golex.Board.become_alive_tick(alive_cells)
    expected_born_cells = [{1, -1}, {0, 1}, {2, 1}]

    assert born_cells == expected_born_cells
  end
end
