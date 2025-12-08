defmodule Aoc do
  defp parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line
      |> String.split(",", trim: true)
      |> Enum.map(&String.to_integer/1)
      |> then(fn [x, y, z] -> %{x: x, y: y, z: z} end)
    end)
  end

  def part1(input, num_connections_to_take) do
    parse_input(input)
    |> calc_distance_between_pairs()
    |> Enum.sort_by(& &1.distance)
    |> Enum.take(num_connections_to_take)
    |> Enum.reduce(%{}, fn %{dots: {d1, d2}}, dot_to_circuit ->
      c1 = Map.get(dot_to_circuit, d1)
      c2 = Map.get(dot_to_circuit, d2)
      cond do
        c1 != nil and c1 == c2 -> dot_to_circuit

        c1 != nil and c2 != nil ->
          updated_dots = for {dot, ^c2} <- dot_to_circuit, into: %{}, do: {dot, c1}
          Map.merge(dot_to_circuit, updated_dots)

        c1 != nil -> Map.put(dot_to_circuit, d2, c1)

        c2 != nil -> Map.put(dot_to_circuit, d1, c2)

        true ->
          cid = make_ref()
          Map.merge(dot_to_circuit, %{d1 => cid, d2 => cid})
      end
    end)
    |> Map.values()
    |> Enum.frequencies()
    |> Map.values()
    |> Enum.sort(:desc)
    |> Enum.take(3)
    |> Enum.product()
  end

  def part2(input) do
    dots = parse_input(input)

    initial_circuits = {
      Map.new(dots, fn dot -> {dot, make_ref()} end),
      length(dots)
    }

    dots
    |> calc_distance_between_pairs()
    |> Enum.sort_by(& &1.distance)
    |> Enum.reduce_while(initial_circuits, fn connection, {circuits, circuit_count} ->
      %{dots: {d1, d2}} = connection

      c1 = Map.fetch!(circuits, d1)
      c2 = Map.fetch!(circuits, d2)

      if c1 == c2 do
        {:cont, {circuits, circuit_count}}
      else
        updates = for {dot, ^c2} <- circuits, into: %{}, do: {dot, c1}
        remaining_circuits = circuit_count - 1

        if remaining_circuits == 1 do
          {:halt, d1.x * d2.x}
        else
          {:cont, {Map.merge(circuits, updates), remaining_circuits}}
        end
      end
    end)
  end

  defp calc_distance_between_pairs(dots, distances \\ [])

  defp calc_distance_between_pairs([], distances), do: distances

  defp calc_distance_between_pairs([curr | rest], distances) do
    new_distances =
      Enum.reduce(rest, distances, fn other, calculated ->
        dist =
          Integer.pow(curr.x - other.x, 2) +
          Integer.pow(curr.y - other.y, 2) +
          Integer.pow(curr.z - other.z, 2)

        [%{dots: {curr, other}, distance: dist} | calculated]
      end)

    calc_distance_between_pairs(rest, new_distances)
  end
end

sample = File.read!("./sample.txt")
input = File.read!("./input.txt")

IO.puts("--- Part 1 ---")
sample |> Aoc.part1(10) |> IO.inspect(label: "Sample")
input  |> Aoc.part1(1000) |> IO.inspect(label: "Input")

IO.puts("\n--- Part 2 ---")
sample |> Aoc.part2() |> IO.inspect(label: "Sample")
input  |> Aoc.part2() |> IO.inspect(label: "Input")
