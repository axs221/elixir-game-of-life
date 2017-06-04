defmodule GameOfLife do
  @iterations 10
  @delay_ms 100

  def generate_board do
    generate = ( fn (inner_fun) -> Enum.map(1..10, fn _ -> inner_fun.() end) end ) 

    cell = fn -> generate.( fn ->
        case round(:rand.uniform()) do
          0 -> false
          1 -> true
        end
      end )
    end

    generate.( fn  -> cell.() end )
  end

  def get_neighbors(x, y) do
    not_current_cell = fn x, y -> x !== 0 || y !== 0 end
    not_too_small = fn x, y -> x >= 0 && y >= 0 end
    not_too_large = fn x, y -> x < 10 && y < 10 end
    Enum.flat_map(for xo <- -1..1 do
      for yo <- -1..1,
      not_current_cell.(xo, yo),
      not_too_small.(x + xo, y + yo),
      not_too_large.(x + xo, y + yo) do
        %{x: x + xo, y: y + yo}
      end
    end, fn x -> x end)
  end

  def determine_is_alive(cell, board, x, y) do
    get_cell = fn n -> Enum.at(Enum.at(board, n.x), n.y) end

    currently_alive = elem(cell, 0)
    alive_neighbors_count = get_neighbors(x, y)
      |> Enum.map(&get_cell.(&1))
      |> Enum.reduce(0, fn n, acc -> case n do
        false -> acc
        true -> acc + 1
      end end)
    
    result = cond do
      currently_alive && alive_neighbors_count < 2 -> false
      currently_alive && alive_neighbors_count in [2, 3] -> true
      currently_alive && alive_neighbors_count > 3 -> false
      !currently_alive && alive_neighbors_count == 3 -> true
      true -> currently_alive
    end

    result
  end

  def iterate(board, i) when i < @iterations do
    new_board = Enum.map(Enum.with_index(board), fn row ->
      Enum.map(Enum.with_index(elem(row, 0)), fn cell ->
        result = determine_is_alive(cell, board, elem(row, 1), elem(cell, 1))
        result
      end)
    end)

    print_board new_board
    Process.sleep(@delay_ms)
    iterate(new_board, i+1)
  end

  def iterate(board, i) do
    []
  end

  def print_board(board) do
    IO.puts "-----------------"
    IO.puts(for row <- board do
      (for cell <- row do
        case cell do
          false -> ' '
          true -> '*'
        end
      end) ++ "\n"
    end)
  end

  def run do
    board = generate_board()
    print_board board

    iterate board, 0 
  end
end

GameOfLife.run
