defmodule Aoc do
  def part1(input) do
    Grid.build_grid(input, ["@"])
    |> accessible_rolls_positions()
    |> length()
  end

  def part2(input) do
    grid = Grid.build_grid(input, ["@"])
    cleaned_grid = drop_accessible_rolls_recursive(grid)
    map_size(grid) - map_size(cleaned_grid)
  end

  def accessible_rolls_positions(grid) do
    for {position, _} <- grid,
      Enum.count(Grid.neigbouring_positions(position), &Map.has_key?(grid, &1)) < 4,
      do: position
  end

  def drop_accessible_rolls_recursive(grid) do
    case accessible_rolls_positions(grid) do
      [] -> grid
      rolls_to_remove -> grid
        |> Map.drop(rolls_to_remove)
        |> drop_accessible_rolls_recursive()
    end
  end
end

defmodule Grid do
  def build_grid(input, cells_to_keep) do
    for {line, row} <- Enum.with_index(String.split(input, "\n", trim: true)),
        {cell, col} <- Enum.with_index(String.graphemes(line)),
        cell in cells_to_keep,
        into: %{},
        do: {{col, row}, cell}
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
input = File.read!("./input.txt")

IO.puts("--- Part 1 ---")
sample |> Aoc.part1() |> IO.inspect(label: "Sample")
input  |> Aoc.part1() |> IO.inspect(label: "Input")

IO.puts("\n--- Part 2 ---")
sample |> Aoc.part2() |> IO.inspect(label: "Sample")
input  |> Aoc.part2() |> IO.inspect(label: "Input")
