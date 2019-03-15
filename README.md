# SoundFeed

<p align="center">
  <img src="screenshot.png?raw=true" alt="Screenshot of SoundFeed"/>
</p>

## Prerequisites

- Elixir
- Node
- Docker (only necessary to create a release)

## Installation

First create an `env` file in the root directory of the application with your SoundCloud `client_id` and a cookie value:

```plaintext
CLIENT_ID=$your_client_id
ERLANG_COOKIE=$secret
```

Then start the application with:

```bash
make install
make start
```

## Release

To build a minimal Docker container that runs the release:

```bash
make build
make start-release
```
