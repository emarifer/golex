defmodule Golex.Utilities.PatternConverter do
  @doc """
  Performs a translation movement of a pattern,
  or in general of a set of cells, to a specified position.

  ## Example
    iex> Golex.Utilities.PatternConverter.transit([{0, 0}, {1, 3}], -1, 2)
    [{-1, 2}, {0, 5}]
  """
  def transit([{x, y} | cells], x_padding, y_padding) do
    [{x + x_padding, y + y_padding} | transit(cells, x_padding, y_padding)]
  end

  def transit([], _x_padding, _y_padding), do: []
end
