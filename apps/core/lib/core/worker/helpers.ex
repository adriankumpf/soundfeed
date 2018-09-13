defmodule Core.Worker.Helpers do
  @spec randomize(integer, integer) :: integer
  def randomize(val, factor) do
    m = trunc(val * factor)
    rnd = :rand.uniform(2 * m + 1) - m - 1
    val + rnd
  end
end
