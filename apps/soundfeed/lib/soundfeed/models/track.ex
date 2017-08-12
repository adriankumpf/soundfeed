defmodule Soundfeed.Models.Track do
  defstruct [:id, :title, :permalink_url, :description,
             :download_url, :artwork_url, :duration,
             :streamable, :stream_url]
end
