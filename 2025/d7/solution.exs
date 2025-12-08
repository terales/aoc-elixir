defmodule Aoc do
  def part1(input) do
    Grid.build(input, ["S", "^", "."])
    |> Grid.replace_start("|")
    |> shine()
    |> then(fn {_, splits_total} -> splits_total end)
  end

  def part2(input) do
    Grid.build(input, ["S", "^", "."])
    |> Grid.replace_start(1)
    |> split_time()
    |> then(fn grind_enlightened ->
      last_row =
        grind_enlightened
        |> Enum.map(fn {{_, row}, _} -> row end)
        |> Enum.max()

      grind_enlightened
      |> Enum.filter(&match?({{_, ^last_row}, power} when is_integer(power), &1))
      |> Enum.map(fn {_, power} -> power end)
      |> Enum.sum()
    end)
  end

  defp shine(grid, curr_row \\ 0, splits \\ 0) do
    grid
    |> Enum.filter(&match?({{_, ^curr_row}, "|"}, &1))
    |> Enum.map(&elem(&1, 0))
    |> Enum.reduce({grid, splits, 0}, fn curr_beam, {grid_previous, splits, _} ->
      next_beams = Grid.move(grid_previous, curr_beam)

      grid_changed =
        next_beams
        |> Enum.reduce(grid_previous, fn next_beam, grid_new ->
          Map.update(grid_new, next_beam, "|", fn _ -> "|" end)
        end)

      splits = if length(next_beams) == 2, do: splits + 1, else: splits

      {grid_changed, splits, length(next_beams)}
    end)
    |> then(fn {grid_changed, splits, next_beams_len} ->
      if next_beams_len == 0,
        do: {grid_changed, splits},
        else: shine(grid_changed, curr_row + 1, splits)
    end)
  end

  defp split_time(grid, curr_row \\ 0) do
    grid
    |> Enum.filter(fn {{_, row}, val} -> row == curr_row and is_integer(val) end)
    |> Enum.reduce(grid, fn {curr_pos, curr_beam_power}, grid_before ->
      grid_before
      |> Grid.move(curr_pos)
      |> Enum.reduce(grid_before, fn next_move, grid_after ->
        prev_next_beam_power = Map.get(grid_after, next_move, "")

        new_next_power = fn _ ->
          if is_integer(prev_next_beam_power),
            do: prev_next_beam_power + curr_beam_power,
            else: curr_beam_power
        end

        Map.update(grid_after, next_move, "", new_next_power)
      end)
    end)
    |> then(fn grid_changed ->
      if grid_changed != grid,
        do: split_time(grid_changed, curr_row + 1),
        else: grid_changed
    end)
  end
end

defmodule Grid do
  def build(input, cells_to_keep) do
    for {line, row} <- Enum.with_index(String.split(input, "\n", trim: true)),
      {cell, col} <- Enum.with_index(String.graphemes(line)),
      cell in cells_to_keep,
      into: %{},
      do: {{col, row}, cell}
  end

  def replace_start(grid, new_value) do
    grid
    |> Enum.find(&match?({_, "S"}, &1))
    |> then(fn {start_pos, _} ->
      Map.update(grid, start_pos, "S", fn _ -> new_value end)
    end)
  end

  def move(grid, { curr_col, curr_row }) do
    next_pos = { curr_col, curr_row + 1}
    case Map.get(grid, next_pos) do
        "^" -> [{ curr_col - 1, curr_row + 1}, { curr_col + 1, curr_row + 1}]
        "." -> [next_pos]
        "|" -> [next_pos]
        v when is_integer(v) -> [next_pos]
        _ -> []
    end
  end

  def print(grid) do
    xs = grid |> Map.keys() |> Enum.map(&elem(&1, 0))
    ys = grid |> Map.keys() |> Enum.map(&elem(&1, 1))

    min_x = Enum.min(xs)
    max_x = Enum.max(xs)
    min_y = Enum.min(ys)
    max_y = Enum.max(ys)

    for y <- min_y..max_y do
      for x <- min_x..max_x do
        Map.get(grid, {x, y}, ".")
      end
      |> Enum.join()
      |> IO.puts
    end
  end
end

sample = File.read!("./sample.txt")
input = File.read!("./input.txt")

IO.puts("--- Part 1 ---")
sample |> Aoc.part1() |> IO.inspect(label: "Sample")
input  |> Aoc.part1() |> IO.inspect(label: "Input")

IO.puts("\n--- Part 2 ---")
sample |> Aoc.part2() |> IO.inspect(label: "Sample")
input  |> Aoc.part2() |> IO.inspect(label: "Input")
