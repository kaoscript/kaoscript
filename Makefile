bin:
	./bin/kaoscript -c --no-register -t ecma-v5 -o lib -r src/compiler.ks=lib/compiler.js src/bin.ks

comp:
	time ./bin/kaoscript -c -t ecma-v6 -o lib -m src/compiler.ks

build:
	time ./bin/kaoscript -c -t ecma-v5 -o lib src/compiler.ks
	cp lib/compiler.js ../compiler-bin-js-es5
	time ./bin/kaoscript -c -t ecma-v6 -o lib src/compiler.ks
	cp lib/compiler.js ../compiler-bin-js-es6

test:
ifeq ($(g),)
	node_modules/.bin/mocha --colors --check-leaks --reporter spec
else
	node_modules/.bin/mocha --colors --check-leaks --reporter spec -g "$(g)"
endif

testks:
ifeq ($(g),)
	node_modules/.bin/mocha --colors --check-leaks --reporter spec --require ./register.js
else
	node_modules/.bin/mocha --colors --check-leaks --reporter spec --require ./register.js -g "$(g)"
endif

coverage:
ifeq ($(g),)
	./node_modules/@zokugun/istanbul.cover/src/cli.js
else
	./node_modules/@zokugun/istanbul.cover/src/cli.js "$(g)"
endif

clean:
	./bin/kaoscript --clean

ok:
	make clean
	make comp
	make comp
	make comp
	make testks
	make build

.PHONY: test build bin comp coverage