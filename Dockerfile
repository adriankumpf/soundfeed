FROM hexpm/elixir:1.12.3-erlang-24.0.6-alpine-3.14.0 as builder

RUN apk add --update --no-cache nodejs npm git build-base && \
    mix local.rebar --force && \
    mix local.hex --force

ENV MIX_ENV=prod

WORKDIR /opt/app

COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV

COPY config/$MIX_ENV.exs config/$MIX_ENV.exs
COPY config/config.exs config/config.exs
RUN mix deps.compile

COPY assets/package.json assets/package-lock.json ./assets/
RUN npm ci --prefix ./assets --progress=false --no-audit --loglevel=error

COPY assets assets
RUN npm run deploy --prefix ./assets
RUN mix phx.digest

COPY lib lib
COPY priv/gettext priv/gettext
RUN mix compile

COPY config/runtime.exs config/runtime.exs
RUN mix release --path /opt/built

########################################################################

FROM alpine:3.14 AS app

ENV LANG=C.UTF-8 \
    HOME=/opt/app

RUN apk add --no-cache ncurses-libs ca-certificates libstdc++

WORKDIR $HOME
RUN chown -R nobody:nobody .
USER nobody:nobody

COPY --from=builder --chown=nobody:nobody /opt/built .

EXPOSE 4000

CMD ["bin/soundfeed", "start"]
