defmodule Aoc do
  defp parse_input(input) do
    String.split(input, ",", trim: true)
    |> Enum.map(fn v -> String.split(v, "-") |> Enum.map(&String.to_integer/1) end)
  end

  def part1(input) do
    parse_input(input)
    |> Enum.flat_map(fn [min, max] -> Enum.filter(min..max, &is_invalid_id_part1?/1) end)
    |> Enum.sum()
  end

  defp is_invalid_id_part1?(i) do
    s = Integer.to_string(i)
    {l, r} = String.split_at(s, floor(String.length(s) / 2))
    l == r
  end

  defp is_invalid_id_part2?(i) do
    s = Integer.to_string(i)
    half_length = floor(String.length(s) / 2)
    if half_length > 0 do
      possible_chunks = 1..half_length
      Enum.any?(possible_chunks, fn chunk_size ->
        chunks = Enum.chunk_every(String.graphemes(s), chunk_size)
        Enum.all?(chunks, &(&1 == hd(chunks)))
      end)
    else
      false
    end
  end

  def part2(input) do
    parse_input(input)
    |> Enum.flat_map(fn [min, max] -> Enum.filter(min..max, &is_invalid_id_part2?/1) end)
    |> Enum.sum()
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
