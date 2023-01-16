bin:
	./bin/kaoscript -c --no-register -t ecma-v6 -o lib -r src/compiler.ks=lib/compiler.js src/bin.ks

comp:
	time ./bin/kaoscript -c -t ecma-v6 -o lib -m src/compiler.ks

build:
	time ./bin/kaoscript -c -t ecma-v6 -o lib src/compiler.ks
	cp lib/compiler.js ../compiler-bin-js-es6
	cp lib/compiler.js ../../ZokugunKS/lang/node_modules/kaoscript/lib/compiler.js
	cp lib/compiler.js ../highlight-tmlanguage/node_modules/kaoscript/lib/compiler.js

cls:
	printf '\033[2J\033[3J\033[1;1H'

test:
	node_modules/.bin/mocha --colors --check-leaks --reporter spec$(if $(q), --no-diff)$(if $(value g), -g "$(g)") test/*.test.js

testks:
	node_modules/.bin/mocha --colors --check-leaks --reporter spec$(if $(q), --no-diff)$(if $(value g), -g "$(g)") test/*.test.js test/*.ks

coverage:
	./node_modules/@zokugun/istanbul.cover/src/cli.js$(if $(value g), "$(g)")

clean:
	./bin/kaoscript --clean

ok:
	@make cls
	@make std
	@make clean
	make comp
	make comp
	make comp
	make testks
	make build

new:
	mv lib/compiler.js lib/compiler.new.js
	gsed -i -E 's/compiler(.old)?.js/compiler.new.js/' lib/bin.js

old:
	if [ -f "lib/compiler.new.js" ]; then mv lib/compiler.new.js lib/compiler.js; fi;
	gsed -i -E 's/compiler(.new)?.js/compiler.old.js/' lib/bin.js

std:
	gsed -i -E 's/compiler(.new|.old).js/compiler.js/' lib/bin.js

save:
	cp lib/compiler.js lib/compiler.old.js

restore:
	cp lib/compiler.old.js lib/compiler.js

update:
	@make clean
	rm -rf node_modules package-lock.json
	nrm use local
	npm i

local:
	@make save
	nrm use local
	npm unpublish kaoscript --force
	npm publish
	@make restore

dev: export DEBUG = 1
dev: export XARGS = 1
dev:
	@# use 4-length tabs
	@# @tabs -4

	@# clear terminal
	@make cls

	@# remove precompiled files
	@# @make clean

	@# compile compiler
	@# @make comp

	@# tests
	@# node test/compile.dev.js "compile "
	node test/compile.dev.js "compile test"

	@# node test/evaluate.dev.js "evaluate "
	@# node test/evaluate.dev.js "evaluate test"

	@# npx mocha --colors --check-leaks --reporter spec --require ./register.js test/*.ks -g "disk"

.PHONY: test build bin comp coverage
