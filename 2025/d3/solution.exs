defmodule Aoc do
  defp parse_input(input) do
    String.split(input, "\n", trim: true)
    |> Enum.map(fn l -> String.graphemes(l) |> Enum.map(&String.to_integer/1) end)
  end

  def part1(input) do
    parse_input(input)
    |> Enum.map(&calc_max_joltage(&1, 2))
    |> Enum.sum()
  end

  def part2(input) do
    parse_input(input)
    |> Enum.map(&calc_max_joltage(&1, 12))
    |> Enum.sum()
  end

  defp calc_max_joltage(_bank, 0), do: 0

  defp calc_max_joltage(bank, max_batteries) do
    search_window_size = length(bank) - max_batteries + 1
    search_window = Enum.take(bank, search_window_size)

    {max_val, max_index} = search_window
      |> Enum.with_index()
      |> Enum.max_by(fn {val, _idx} -> val end)

    remaining_bank = Enum.drop(bank, max_index + 1)

    current_tens_place = max_val * 10 ** (max_batteries - 1)

    current_tens_place + calc_max_joltage(remaining_bank, max_batteries - 1)
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
