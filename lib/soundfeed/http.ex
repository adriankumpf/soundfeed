defmodule SoundFeed.HTTP do
  @pools %{
    "http://api.soundcloud.com" => [size: 25],
    "https://api-v2.soundcloud.com" => [size: 10],
    :default => [size: 5]
  }

  @pool_timeout 10_000

  def child_spec(arg) do
    %{
      id: __MODULE__,
      start: {Finch, :start_link, [Keyword.merge([name: __MODULE__, pools: @pools], arg)]}
    }
  end

  def get(url, opts \\ []) do
    {headers, opts} =
      opts
      |> Keyword.put_new(:pool_timeout, @pool_timeout)
      |> Keyword.pop(:headers, [])

    Finch.build(:get, url, headers, nil)
    |> Finch.request(__MODULE__, opts)
  end

  def post(url, body \\ nil, opts \\ []) do
    {headers, opts} =
      opts
      |> Keyword.put_new(:pool_timeout, @pool_timeout)
      |> Keyword.pop(:headers, [])

    Finch.build(:post, url, headers, body)
    |> Finch.request(__MODULE__, opts)
  end
end
