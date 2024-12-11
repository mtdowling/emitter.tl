.PHONY: dev build gen check test compile

VERSION=0.1.0

build: compile check test build

dev:
	luarocks install cyan

compile:
	cyan build
	luarocks build

check: compile
	tl check -q spec/integ.tl
	luacheck src/emitter.lua

test: compile
	luarocks test

newrock:
	luarocks new_version --dir rockspecs --tag=v$(VERSION) emitter.tl-dev-1.rockspec $(VERSION)
