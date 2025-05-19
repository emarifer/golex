defmodule Golex.NodeManager do
  def all_nodes, do: [Node.self() | Node.list()]

  def random_node, do: all_nodes() |> Enum.random()
end
