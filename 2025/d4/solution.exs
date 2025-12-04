defmodule Aoc do
  defp parse_input(input) do
    Grid.build_grid(input)
    |> Grid.take_cells(["@"])
  end

  def part1(input) do
    parse_input(input)
    |> accessible_rols_positions()
    |> Enum.count()
  end

  def part2(input) do
    parse_input(input)
    |> drop_accessible_rolls_recursive()
  end

  def accessible_rols_positions(grid) do
    grid
    |> Map.keys()
    |> Enum.filter(fn position ->
      Enum.count(Grid.neigbouring_positions(position), &Map.has_key?(grid, &1)) < 4
    end)
  end

  def drop_accessible_rolls_recursive(grid, rolls_removed \\ 0) do
    rolls_to_remove = accessible_rols_positions(grid)

    case rolls_to_remove do
      [] -> rolls_removed
      _ -> grid
        |> Map.drop(rolls_to_remove)
        |> drop_accessible_rolls_recursive(rolls_removed + length(rolls_to_remove))
    end
  end
end

defmodule Grid do
  def build_grid(input) do
    lines = String.split(input, "\n", trim: true)

    for {line, row} <- Enum.with_index(lines),
        {char, col} <- Enum.with_index(String.to_charlist(line)),
        into: %{} do
      {{col, row}, <<char>>}
    end
  end

  def take_cells(grid, values_to_keep) do
    Map.filter(grid, fn {_, value} -> value in values_to_keep end)
  end

  def neigbouring_positions({col, row}) do
    [
      { col - 1, row - 1 }, { col, row - 1 }, { col + 1, row - 1 },
      { col - 1, row     },                   { col + 1, row     },
      { col - 1, row + 1 }, { col, row + 1 }, { col + 1, row + 1 },
    ]
  end
end

sample = File.read!("./sample.txt")
IO.puts "Sample (part 1)"
IO.inspect(Aoc.part1(sample))

input = File.read!("./input.txt")
IO.puts "Part 1"
IO.puts Aoc.part1(input)

sample = File.read!("./sample.txt")
IO.puts "Sample (part 2)"
IO.inspect(Aoc.part2(sample))

input = File.read!("./input.txt")
IO.puts "Part 2"
IO.puts Aoc.part2(input)
