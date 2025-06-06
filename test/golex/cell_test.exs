defmodule Golex.CellTest do
  use ExUnit.Case, async: true

  test "alive cell with no neighbours dies" do
    alive_cell = {1, 1}
    alive_cells = [alive_cell]

    refute Golex.Cell.keep_alive?(alive_cells, alive_cell)
  end

  test "alive cell with 1 neighbour dies" do
    alive_cell = {1, 1}
    alive_cells = [alive_cell, {0, 0}]

    refute Golex.Cell.keep_alive?(alive_cells, alive_cell)
  end

  test "alive cell with more than 3 neighbours dies" do
    alive_cell = {1, 1}
    alive_cells = [alive_cell, {0, 0}, {1, 0}, {2, 0}, {2, 1}]

    refute Golex.Cell.keep_alive?(alive_cells, alive_cell)
  end

  test "alive cell with 2 neighbours lives" do
    alive_cell = {1, 1}
    alive_cells = [alive_cell, {0, 0}, {1, 0}]

    assert Golex.Cell.keep_alive?(alive_cells, alive_cell)
  end

  test "alive cell with 3 neighbours lives" do
    alive_cell = {1, 1}
    alive_cells = [alive_cell, {0, 0}, {1, 0}, {2, 1}]

    assert Golex.Cell.keep_alive?(alive_cells, alive_cell)
  end

  test "dead cell with three live neighbours becomes a live cell" do
    dead_cell = {1, 1}
    alive_cells = [{2, 2}, {1, 0}, {2, 1}]

    assert Golex.Cell.become_alive?(alive_cells, dead_cell)
  end

  test "dead cell with two live neighbours stays dead" do
    dead_cell = {1, 1}
    alive_cells = [{2, 2}, {1, 0}]

    refute Golex.Cell.become_alive?(alive_cells, dead_cell)
  end

  test "find dead cells (neighbours of alive cell)" do
    alive_cell = [{1, 1}]
    dead_neighbours = Golex.Cell.dead_neighbours(alive_cell) |> Enum.sort()

    expected_dead_neighbours =
      [
        {0, 0},
        {1, 0},
        {2, 0},
        {0, 1},
        {2, 1},
        {0, 2},
        {1, 2},
        {2, 2}
      ]
      |> Enum.sort()

    assert dead_neighbours == expected_dead_neighbours
  end

  test "find dead cells (neighbours of alive cells)" do
    alive_cells = [{1, 1}, {2, 1}]
    dead_neighbours = Golex.Cell.dead_neighbours(alive_cells) |> Enum.sort()

    expected_dead_neighbours =
      [
        {0, 0},
        {1, 0},
        {2, 0},
        {3, 0},
        {0, 1},
        {3, 1},
        {0, 2},
        {1, 2},
        {2, 2},
        {3, 2}
      ]
      |> Enum.sort()

    assert dead_neighbours == expected_dead_neighbours
  end
end
