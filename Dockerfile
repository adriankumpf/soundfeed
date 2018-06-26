FROM elixir:1.6.6-alpine as asset-builder-mix-getter

ENV HOME=/opt/app

RUN mix do local.hex --force, local.rebar --force

COPY config/ $HOME/config/
COPY mix.exs mix.lock $HOME/
COPY apps/soundfeed_web/mix.exs $HOME/apps/soundfeed_web/
COPY apps/soundfeed_web/config/ $HOME/apps/soundfeed_web/config/
COPY VERSION $HOME/VERSION

WORKDIR $HOME/apps/soundfeed_web
RUN mix deps.get

########################################################################
FROM node:8.11.3-alpine as asset-builder

ENV HOME=/opt/app
WORKDIR $HOME

COPY --from=asset-builder-mix-getter $HOME/deps $HOME/deps

WORKDIR $HOME/apps/soundfeed_web/assets
COPY apps/soundfeed_web/assets/ ./
RUN yarn install
RUN ./node_modules/.bin/brunch build --production

########################################################################
FROM bitwalker/alpine-elixir:1.6.6 as releaser

ENV HOME=/opt/app

ARG CLIENT_ID
ENV CLIENT_ID $CLIENT_ID

# Install Hex + Rebar
RUN mix do local.hex --force, local.rebar --force

# Cache elixir deps
COPY mix.exs mix.lock $HOME/

# Copy  mix.exs files
COPY apps/soundfeed_core/mix.exs $HOME/apps/soundfeed_core/
COPY apps/soundfeed_web/mix.exs $HOME/apps/soundfeed_web/
COPY VERSION $HOME/VERSION

# Install dependencies
ENV MIX_ENV=prod
RUN mix do deps.get --only $MIX_ENV, deps.compile

COPY . $HOME/

# Digest precompiled assets
COPY --from=asset-builder $HOME/apps/soundfeed_web/priv/static/ $HOME/apps/soundfeed_web/priv/static/
WORKDIR $HOME/apps/soundfeed_web
RUN mix phx.digest

# Release
WORKDIR $HOME
RUN mix release --env=$MIX_ENV --verbose

########################################################################
FROM alpine:3.7

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

RUN addgroup -g 1000 soundfeed && \
    adduser -u 1000 -D -h $HOME -G soundfeed soundfeed
USER soundfeed

COPY --from=releaser $HOME/_build/prod/rel/soundfeed/releases/$VERSION/soundfeed.tar.gz $HOME

RUN tar -xzf soundfeed.tar.gz

ENTRYPOINT ["/opt/app/bin/soundfeed"]
CMD ["foreground"]
