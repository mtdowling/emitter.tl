.PHONY: dev build gen check test compile

VERSION=0.2.0

build: compile check test

dev:
	luarocks install busted
	luarocks install cyan
	luarocks install --server=https://luarocks.org/dev busted-tl

compile:
	cyan build
	luarocks build

check: compile
	tl check -q spec/integ.tl
	luacheck src/emitter.lua

test: compile
	luarocks test

clean:
	rm -rf build

newrock:
	luarocks new_version --dir build --tag=v$(VERSION) emitter.tl-dev-1.rockspec $(VERSION)
