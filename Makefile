CWD=$(shell pwd)
ASSETS?=${CWD}/apps/server/assets
BRUNCH?=${ASSETS}/node_modules/brunch/bin/brunch

all: clean compile

clean:
	mix do clean, phx.digest.clean, release.clean

compile:
	${BRUNCH} b -p ${ASSETS} && MIX_ENV=prod mix do phx.digest, release

getdeps:
	mix deps.get && cd ${ASSETS} && npm install && cd ${CWD}

shell:
	iex -S mix phx.server
