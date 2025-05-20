defmodule Golex.Console do
  @doc """
  It prints the board correctly with X & Y axes,
  the number of alive cells, and the generation counter.
  Print cells to the console output. Board is visible
  only for specified size for x and y. Start x and y are
  in top left corner of the board.

  `x_padding` Must be a prime number. Every x divided by the prime number
  will be visible on x axis.
  `y_padding` Any number. Padding for numbers on y axis.
  """
  def print(
        cells,
        generation_counter,
        alive_counter,
        start_x \\ -10,
        start_y \\ 15,
        x_size \\ 60,
        y_size \\ 20,
        x_padding \\ 5,
        y_padding \\ 5
      ) do
    end_x = start_x + x_size
    end_y = start_y - y_size
    # ↑↑↑ To calculate the range on the Y axis, we start counting ↑↑↑
    # from the top, so we do a subtraction.
    # ↓↓↓ Hence we use a negative step in `start_y..end_y//-1` ↓↓↓
    x_range = start_x..end_x
    y_range = start_y..end_y//-1

    for y <- y_range, x <- x_range do
      # Draw `Y` axis
      if x == start_x do
        ((y
          |> Integer.to_string()
          |> String.pad_leading(y_padding)) <> "| ")
        |> IO.write()
      end

      # Draw the living or dead cells.
      IO.write(if Enum.member?(cells, {x, y}), do: "O", else: ",")
      if x == end_x, do: IO.puts("")
    end

    # Draw `X` axis
    IO.write(String.pad_leading("| ", y_padding + 2))
    x_length = round((end_x - start_x) / 2)

    for _x <- 0..x_length, do: IO.write("_ ")
    IO.puts("")

    IO.write(String.pad_leading("/  ", y_padding + 2))

    for x <- x_range do
      if rem(x, x_padding) == 0 do
        x
        |> Integer.to_string()
        |> String.pad_trailing(x_padding)
        |> IO.write()
      end
    end

    IO.puts("")

    IO.puts("Generation: #{generation_counter}")
    IO.puts("Alive cells: #{alive_counter}")
  end
end
