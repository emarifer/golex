defmodule Golex.ConsoleTest do
  use ExUnit.Case

  # Allows to capture stuff sent to stdout.
  # See: https://hexdocs.pm/ex_unit/ExUnit.CaptureIO.html
  import ExUnit.CaptureIO

  test "print cells on the console output" do
    cell_outside_of_board = {-1, -1}
    cells = [{0, 0}, {1, 0}, {2, 0}, {1, 1}, {0, 2}, cell_outside_of_board]

    result =
      capture_io(fn ->
        # Values ​​that are not present are the default values.
        Golex.Console.print(cells, 123, length(cells), 0, 2, 2, 2)
      end)

    assert result ==
             "    2| ◻️◼️◼️\n" <>
               "    1| ◼️◻️◼️\n" <>
               "    0| ◻️◻️◻️\n" <>
               "     | _ _ \n" <>
               "    /  0    \n" <>
               "Generation: 123\n" <>
               "Alive cells: 6\n"
  end
end
