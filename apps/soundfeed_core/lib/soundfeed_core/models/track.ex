defmodule SoundfeedCore.Models.Track do
  defstruct [:id, :title, :permalink_url, :desc,
             :download_url, :artwork_url, :duration,
             :streamable, :stream_url]

  @type id :: String.t
  @type t :: %__MODULE__{
    id: id,
    title: String.t,
    permalink_url: String.t,
    desc: String.t,
    download_url: String.t,
    artwork_url: String.t,
    duration: integer,
    streamable: boolean,
    stream_url: String.t
  }
end
