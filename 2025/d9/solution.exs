defmodule Aoc do
  require Integer
  defp parse_input(input) do
    for line <- String.split(input, "\n", trim: true) do
      [x, y] = String.split(line, ",")
      {String.to_integer(x), String.to_integer(y)}
    end
  end

  def part1(input) do
    input
    |> parse_input()
    |> assemble_rectangles()
    |> Enum.map(&calc_rectangle_area/1)
    |> Enum.max()
  end

  def part2(input) do
    points = parse_input(input)
    [first_point | remaining_points] = points

    edges = Enum.zip(points, remaining_points ++ [first_point])

    points
    |> assemble_rectangles()
    |> Enum.map(fn rectangle -> {rectangle, calc_rectangle_area(rectangle)} end)
    |> Enum.sort_by(fn {_, area} -> area end, :desc)
    |> Enum.find_value(fn {{{x1, y1}, {x2, y2}}, area} ->
      rectangle_normalized = {
        min(x1, x2), max(x1, x2),
        min(y1, y2), max(y1, y2)
      }

      is_fully_inside? =
        not Enum.any?(edges, &edge_intersects_rect?(&1, rectangle_normalized))

      if is_fully_inside?, do: area
    end)
  end

  defp assemble_rectangles(points) do
    for {p1, i} <- Enum.with_index(points),
        p2 <- Enum.drop(points, i + 1),
        do: {p1, p2}
  end

  defp calc_rectangle_area({{x1, y1}, {x2, y2}}) do
    (abs(x1 - x2) + 1) * (abs(y1 - y2) + 1)
  end

  defp edge_intersects_rect?(
    {{edge_start_x, edge_start_y}, {edge_end_x, edge_end_y}},
    {rect_min_x, rect_max_x, rect_min_y, rect_max_y}
  ) do
    cond do
      edge_start_x == edge_end_x ->
        vertical_edge_x = edge_start_x
        edge_lower_y = min(edge_start_y, edge_end_y)
        edge_upper_y = max(edge_start_y, edge_end_y)

        within_x_boundaries? = vertical_edge_x > rect_min_x and vertical_edge_x < rect_max_x
        y_overlaps? = edge_lower_y < rect_max_y and edge_upper_y > rect_min_y

        within_x_boundaries? and y_overlaps?

      edge_start_y == edge_end_y ->
        horizontal_edge_y = edge_start_y
        edge_lower_x = min(edge_start_x, edge_end_x)
        edge_upper_x = max(edge_start_x, edge_end_x)

        within_y_boundaries? = horizontal_edge_y > rect_min_y and horizontal_edge_y < rect_max_y
        x_overlaps? = edge_lower_x < rect_max_x and edge_upper_x > rect_min_x

        within_y_boundaries? and x_overlaps?

      true ->
        false
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
