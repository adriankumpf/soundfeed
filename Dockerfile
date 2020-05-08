FROM elixir:1.10-alpine AS builder

RUN apk add --update --no-cache nodejs npm git build-base python && \
    mix local.rebar --force && \
    mix local.hex --force

ENV MIX_ENV=prod

WORKDIR /opt/app

COPY mix.exs mix.lock ./
COPY config config
RUN mix "do" deps.get --only $MIX_ENV, deps.compile

COPY assets/package.json assets/package-lock.json ./assets/
RUN npm ci --prefix ./assets --progress=false --no-audit --loglevel=error

COPY assets assets
RUN npm run deploy --prefix ./assets
RUN mix phx.digest

COPY lib lib
COPY priv/gettext priv/gettext

RUN mkdir -p /opt/built && \
    mix "do" compile, release --path /opt/built

########################################################################

FROM alpine:3.11 AS app

ENV LANG=C.UTF-8 \
    HOME=/opt/app

RUN apk add --no-cache ncurses-libs openssl tzdata

WORKDIR $HOME
RUN chown -R nobody:nobody .
USER nobody:nobody

COPY --from=builder --chown=nobody:nobody /opt/built .

EXPOSE 4000

CMD ["bin/soundfeed", "start"]
