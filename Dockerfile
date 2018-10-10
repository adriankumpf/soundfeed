FROM elixir:1.8-alpine as asset-builder-mix-getter

ENV HOME=/opt/app

RUN mix do local.hex --force, local.rebar --force

COPY config/ $HOME/config/
COPY mix.exs mix.lock $HOME/
COPY apps/ui/mix.exs $HOME/apps/ui/
COPY apps/ui/config/ $HOME/apps/ui/config/
COPY VERSION $HOME/VERSION

WORKDIR $HOME/apps/ui
RUN mix deps.get

########################################################################
FROM node:10-alpine as asset-builder

ENV HOME=/opt/app
WORKDIR $HOME

COPY --from=asset-builder-mix-getter $HOME/deps $HOME/deps

WORKDIR $HOME/apps/ui/assets
COPY apps/ui/assets/ ./
RUN yarn install
RUN yarn run deploy

########################################################################
FROM elixir:1.8-alpine as releaser

ENV HOME=/opt/app

ARG CLIENT_ID
ENV CLIENT_ID $CLIENT_ID

# Install Hex + Rebar
RUN mix do local.hex --force, local.rebar --force

# Cache elixir deps
COPY mix.exs mix.lock $HOME/

# Copy  mix.exs files
COPY apps/core/mix.exs $HOME/apps/core/
COPY apps/ui/mix.exs $HOME/apps/ui/
COPY VERSION $HOME/VERSION

WORKDIR $HOME

# Install dependencies
ENV MIX_ENV=prod
RUN mix do deps.get --only $MIX_ENV, deps.compile

COPY . $HOME/

# Digest precompiled assets
COPY --from=asset-builder $HOME/apps/ui/priv/static/ $HOME/apps/ui/priv/static/
WORKDIR $HOME/apps/ui
RUN mix phx.digest

# Release
WORKDIR $HOME
RUN mix release --env=$MIX_ENV

########################################################################
FROM alpine:3.9

ENV LANG=en_US.UTF-8 \
    HOME=/opt/app/ \
    TERM=xterm

ARG VERSION
ENV VERSION $VERSION

RUN apk add --no-cache ncurses-libs openssl bash

EXPOSE 8080
ENV PORT=8080 \
    HOST=localhost \
    MIX_ENV=prod \
    REPLACE_OS_VARS=true \
    SHELL=/bin/sh

WORKDIR $HOME

RUN addgroup -g 4004 soundfeed && \
    adduser -u 4004 -D -h $HOME -G soundfeed soundfeed
USER soundfeed

COPY --from=releaser $HOME/_build/prod/rel/soundfeed/releases/$VERSION/soundfeed.tar.gz $HOME
RUN tar -xzf soundfeed.tar.gz

ENTRYPOINT ["/opt/app/bin/soundfeed"]
CMD ["foreground"]
