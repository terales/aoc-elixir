defmodule Aoc do
  defp parse_input(input) do
    [ranges_raw, ids_raw] = String.split(input, "\n\n", trim: true)

    ranges = ranges_raw
      |> String.split("\n", trim: true)
      |> Enum.map(fn r ->
        String.split(r, "-")
        |> Enum.map(&String.to_integer/1)
        |> then(fn [min, max] -> min..max end)
      end)

    ids = ids_raw
      |> String.split("\n", trim: true)
      |> Enum.map(&String.to_integer/1)

    {ranges, ids}
  end

  def part1(input) do
    {ranges, ids} = parse_input(input)

    Enum.count(ids, fn id ->
      Enum.any?(ranges, fn range -> id in range end)
    end)
  end

  def part2(input) do
    {ranges, _} = parse_input(input)

    [first_range | remaining_sorted_ranges] = Enum.sort(ranges)

    {last_range, size_prev_ranges} = remaining_sorted_ranges
      |> Enum.reduce({first_range, 0}, &range_reducer/2)

    size_prev_ranges + Range.size(last_range)
  end

  defp range_reducer(curr_range, {prev_range, size_prev_ranges}) do
    if Range.disjoint?(curr_range, prev_range) do
      {curr_range, size_prev_ranges + Range.size(prev_range)}
    else
      max_last = max(prev_range.last, curr_range.last)
      merged_range = prev_range.first..max_last
      {merged_range, size_prev_ranges}
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
