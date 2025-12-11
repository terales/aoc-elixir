defmodule Aoc do
  defp parse_input(input) do
    for line <- String.split(input, "\n", trim: true) do
      line_parts = String.split(line, " ", trim: true)

      target_state =
        line_parts
          |> hd()
          |> String.trim_leading("[")
          |> String.trim_trailing("]")
          |> String.graphemes()
          |> Enum.map(fn "." -> 0; "#" -> 1 end)

      [joltage_raw | buttons_raw] =
        line_parts
        |> tl()
        |> Enum.reverse()

      button_template = List.duplicate(0, length(target_state))

      buttons =
        buttons_raw
        |> Enum.map(&String.trim_leading(&1, "("))
        |> Enum.map(&String.trim_trailing(&1, ")"))
        |> Enum.map(fn btn_string ->
          btn_string
            |> String.split(",", trim: true)
            |> Enum.map(&String.to_integer/1)
            |> Enum.reduce(button_template, fn i, acc ->
              List.replace_at(acc, i, 1)
            end)
        end)

      joltage =
        joltage_raw
        |> String.trim_leading("{")
        |> String.trim_trailing("}")
        |> String.split(",", trim: true)
        |> Enum.map(&String.to_integer/1)

      %{target: target_state, buttons: buttons, joltage: joltage}
    end
  end

  def part1(input) do
    input
    |> parse_input()
    |> Enum.map(&calc_min_buttons_press/1)
    |> Enum.sum()
  end

  def calc_min_buttons_press(%{target: target, buttons: buttons}) do
      [target | buttons]
      |> Enum.reverse()
      |> Enum.zip_with(& &1)
      |> calc_row_echelon_form()
      |> Enum.reject(fn row -> Enum.all?(row, &(&1 == 0)) end)
      |> do_big_brain_bruteforce(length(buttons))
  end

  defp calc_row_echelon_form([]), do: []

  defp calc_row_echelon_form(rows) when is_list(rows) and rows != [] do
    if Enum.all?(rows, &(&1 == [])) do
      rows
    else
      run_calc_row_echelon_form(rows)
    end
  end

  defp run_calc_row_echelon_form(rows) do
    case Enum.sort(rows, :desc) do
      [[0 | _] | _] ->
        rows
        |> Enum.map(&tl/1)
        |> calc_row_echelon_form()
        |> Enum.map(&[0 | &1])

      [[1 | pivot_tail] | others] ->
        reduced_others =
          Enum.map(others, fn
            [1 | tail] -> Enum.zip_with(tail, pivot_tail, &Bitwise.bxor/2)
            [0 | tail] -> tail
          end)

        [[1 | pivot_tail] | Enum.map(calc_row_echelon_form(reduced_others), &[0 | &1])]
    end
  end

  defp do_big_brain_bruteforce(matrix, num_vars) do
    pivots =
      matrix
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {row, r_idx}, acc ->
        col_idx = Enum.find_index(Enum.slice(row, 0..-2//1), &(&1 == 1))
        if col_idx, do: Map.put(acc, r_idx, col_idx), else: acc
      end)

    pivot_cols = Map.values(pivots)
    free_cols = Enum.to_list(0..(num_vars - 1)) -- pivot_cols
    num_combinations = 2 ** length(free_cols)

    0..(num_combinations - 1)
    |> Enum.map(fn i ->
      assignments =
        free_cols
        |> Enum.with_index()
        |> Enum.reduce(%{}, fn {col, bit_idx}, acc ->
          val = Bitwise.band(Bitwise.bsr(i, bit_idx), 1)
          Map.put(acc, col, val)
        end)

      final_assignments =
        matrix
        |> Enum.with_index()
        |> Enum.reverse()
        |> Enum.reduce(assignments, fn {row, r_idx}, acc_assign ->
          case Map.get(pivots, r_idx) do
            nil -> acc_assign
            pivot_col ->
              {coeffs, [target]} = Enum.split(row, -1)

              sum_knowns =
                coeffs
                |> Enum.with_index()
                |> Enum.reduce(0, fn {val, idx}, sum ->
                  if idx != pivot_col and val == 1 do
                    Bitwise.bxor(sum, Map.get(acc_assign, idx, 0))
                  else
                    sum
                  end
                end)

              Map.put(acc_assign, pivot_col, Bitwise.bxor(target, sum_knowns))
          end
        end)

      final_assignments |> Map.values() |> Enum.sum()
    end)
    |> Enum.min(fn -> 0 end)
  end
end

sample = File.read!("./sample.txt")
input = File.read!("./input.txt")

IO.puts("--- Part 1 ---")
sample |> Aoc.part1() |> IO.inspect(label: "Sample")
input  |> Aoc.part1() |> IO.inspect(label: "Input")

# IO.puts("\n--- Part 2 ---")
# sample |> Aoc.part2() |> IO.inspect(label: "Sample")
# input  |> Aoc.part2() |> IO.inspect(label: "Input")
