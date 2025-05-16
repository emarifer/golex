defmodule GolexTest do
  use ExUnit.Case
  doctest Golex

  test "greets the world" do
    assert Golex.hello() == :world
  end
end
