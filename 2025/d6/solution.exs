defmodule Aoc do
  defp parse_input(input) do
    input
    |> String.split("\n", trim: true)
  end

  def part1(input) do
    parse_input(input)
    |> Enum.map(&String.split(&1, " ", trim: true))
    |> Enum.reverse()
    |> Enum.zip_with(& &1)
    |> Enum.reduce(0, fn problem, sum ->
      [operator | operands_raw] = problem
      operands = Enum.map(operands_raw, &String.to_integer/1)
      sum + apply_operator(operands, operator)
    end)
  end

  def part2(input) do
    parse_input(input)
    |> Enum.map(&String.graphemes/1)
    |> then(&zip_uneven_with_padding(&1, " "))
    |> Enum.chunk_by(&empty_column?/1)
    |> Enum.reject(fn column -> empty_column?(hd(column)) end)
    |> Enum.reduce(0, fn problem_raw, sum ->
      operator =
        problem_raw
        |> hd()
        |> List.last()

      operands =
        problem_raw
        |> Enum.map(fn column ->
          column
          |> extract_digits()
          |> Integer.undigits()
        end)

      sum + apply_operator(operands, operator)
    end)
  end

  defp apply_operator(operands, operator) do
    case operator do
      "+" -> Enum.sum(operands)
      "*" -> Enum.product(operands)
      _ -> raise(ArgumentError, "Unexpected operator: #{operator}")
    end
  end

  defp empty_column?(column) do
    Enum.all?(column, &match?(" ", &1))
  end

  defp extract_digits(strings) do
    strings
    |> Enum.flat_map(fn s ->
      case Integer.parse(s) do
        {i, _} -> [i]
        _ -> []
      end
    end)
  end

  defp zip_uneven_with_padding(enumerables, padding) do
    longest_enumerable = enumerables |> Enum.map(&length/1) |> Enum.max()

    enumerables
    |> Enum.map(fn e -> e  ++ List.duplicate(padding, longest_enumerable - length(e)) end)
    |> Enum.zip_with(& &1)
  end

  # # Proud of this function even if generic implementation wasn't needed at the end
  # defp zip_uneven(enumerables) do
  #   unique_filler = make_ref()

  #   enumerables
  #   |> Enum.map(&Stream.concat(&1, Stream.repeatedly(fn -> unique_filler end)))
  #   |> Stream.zip_with(fn column ->
  #     if Enum.all?(column, &match?(^unique_filler, &1)),
  #       do:   :all_fillers,
  #       else: Enum.reject(column, &match?(^unique_filler, &1))
  #   end)
  #   |> Stream.take_while(fn column -> column != :all_fillers end)
  #   |> Enum.to_list()
  # end
end

sample = File.read!("./sample.txt")
input = File.read!("./input.txt")

IO.puts("--- Part 1 ---")
sample |> Aoc.part1() |> IO.inspect(label: "Sample")
input  |> Aoc.part1() |> IO.inspect(label: "Input")

IO.puts("\n--- Part 2 ---")
sample |> Aoc.part2() |> IO.inspect(label: "Sample")
input  |> Aoc.part2() |> IO.inspect(label: "Input")
