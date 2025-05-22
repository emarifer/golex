defmodule Golex.Utilities.Random do
  def random_pattern_generator(amount) when is_integer(amount) do
    for _x <- 1..amount, uniq: true, do: {Enum.random(-10..50), Enum.random(-5..15)}
  end
end
