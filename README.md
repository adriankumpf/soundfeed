# SoundFeed

<p align="center">
  <img src="screenshot.png?raw=true" alt="Screenshot of SoundFeed"/>
</p>

## Prerequisites

- Elixir
- Node
- Docker (only necessary to create a release)

## Installation

First create an `.env` file in the root directory of the application with your
SoundCloud `client_id` and `source` it:

```plaintext
CLIENT_ID=$your_client_id
```

Then run the setup task:

```bash
mix setup
```

And finally start the application with:

```bash
iex -S mix phx.server
```

## Release

To build a minimal Docker container that runs the release:

```bash
make build
```
