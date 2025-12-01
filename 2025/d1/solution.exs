defmodule Aoc do
  def part1(input) do
    parse_input(input)
    |> Enum.reduce({50, 0}, fn rotation, {pos, count} ->
      pos_new = rem(pos + rotation, 100)
      count_new = if pos == 0, do: count + 1, else: count
      {pos_new, count_new}
    end)
    |> elem(1)
  end

  def part2(input) do
    parse_input(input)
    |> Enum.reduce({50, 0}, fn rotation, {pos, count} ->
      next_tick = pos + rotation

      hits = if rotation > 0 do
          floor(next_tick / 100) - floor(pos / 100)
        else
          floor((pos - 1) / 100) - floor((next_tick - 1) / 100)
        end

      {next_tick, count + hits}
    end)
    |> elem(1)
  end

  defp parse_input(input) do
    String.split(input, "\n", trim: true)
    |>  Enum.map(fn
      <<"R", n::binary>> -> String.to_integer(n)
      <<"L", n::binary>> -> -1 * String.to_integer(n)
    end)
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
