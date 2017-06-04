defmodule GameOfLife do
  @iterations 20
  @delay_ms 100

  def generate_board do
    for x <- 0..9, into: %{} do
      { x, for y <- 0..9, into: %{} do
        { y,
          ( if round(:rand.uniform()) == 1, do: true, else: false ) 
        } end 
      } end
  end

  def get_neighbors(current_x, current_y) do
    for x_offset <- -1..1, y_offset <- -1..1,
      x = current_x + x_offset,
      y = current_y + y_offset,
      x in 0..9 && y in 0..9,
      x !== current_x || y !== current_y do
        %{x: x, y: y}
      end
  end

  def determine_is_alive(cell, board, x, y) do
    get_cell = fn n -> board[n.x][n.y] end

    currently_alive = cell
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
    new_board = for x <- 0..9, into: %{} do
      { x, for y <- 0..9, into: %{} do 
        { y,
          determine_is_alive(board[x][y], board, x, y)
        } end 
      } end

    print_board new_board
    Process.sleep(@delay_ms)
    iterate(new_board, i+1)
  end

  def iterate(board, i) do
    []
  end

  def print_board(board) do
    IO.puts "-----------------"
    IO.puts(
      for x <- 0..9 do
        for y <- 0..9 do
          case board[x][y] do
            true  -> '*'
            false -> ' '
          end
        end ++ "\n"
      end
    )
  end

  def run do
    board = generate_board()
    print_board board
    iterate board, 0 
  end
end

GameOfLife.run
