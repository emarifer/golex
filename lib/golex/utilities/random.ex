defmodule Golex.Utilities.Random do
  defguard is_positive(value) when is_integer(value) and value > 0

  @doc """
  Generates a random pattern of live cell positions (tuples) on
  the board (size 60 x 20 cells), given a positive integer initial value.
  The default value is 300 if no value is supplied to the function.
  """
  def random_pattern_generator(amount \\ 300) when is_positive(amount) do
    for _x <- 1..amount, uniq: true, do: {Enum.random(-10..50), Enum.random(-5..15)}
  end
end
