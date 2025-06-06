defmodule Golex.Cell do
  def keep_alive?(alive_cells, {x, y} = _alive_cell) do
    case count_neighbours(alive_cells, x, y, 0) do
      2 -> true
      3 -> true
      _ -> false
    end
  end

  def become_alive?(alive_cells, {x, y} = _dead_cell),
    do: 3 == count_neighbours(alive_cells, x, y, 0)

  def dead_neighbours(alive_cells) do
    neighbours = neighbours(alive_cells, [])

    (neighbours |> Enum.uniq()) -- alive_cells
  end

  # Computes the neighbors of a given cell list.
  defp neighbours([{x, y} | cells], neighbours) do
    neighbours(
      cells,
      neighbours ++
        [
          # down
          {x - 1, y - 1},
          {x, y - 1},
          {x + 1, y - 1},
          # middle
          {x - 1, y},
          {x + 1, y},
          # up
          {x - 1, y + 1},
          {x, y + 1},
          {x + 1, y + 1}
        ]
    )
  end

  defp neighbours([], neighbours), do: neighbours

  defp count_neighbours([head_cell | tail_cells], x, y, count) do
    increment =
      case head_cell do
        # down
        {hx, hy} when hx == x - 1 and hy == y - 1 -> 1
        {hx, hy} when hx == x and hy == y - 1 -> 1
        {hx, hy} when hx == x + 1 and hy == y - 1 -> 1
        # middle
        {hx, hy} when hx == x - 1 and hy == y -> 1
        {hx, hy} when hx == x + 1 and hy == y -> 1
        # up
        {hx, hy} when hx == x - 1 and hy == y + 1 -> 1
        {hx, hy} when hx == x and hy == y + 1 -> 1
        {hx, hy} when hx == x + 1 and hy == y + 1 -> 1
        _not_neighbours -> 0
      end

    count_neighbours(tail_cells, x, y, count + increment)
  end

  defp count_neighbours([], _x, _y, count), do: count
end
