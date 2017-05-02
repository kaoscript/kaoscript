bin:
	./bin/kaoscript -c -t ecma-v5 -o lib -r src/compiler.ks=lib/compiler.js src/bin.ks

comp:
	./bin/kaoscript -c -t ecma-v5 -o lib src/compiler.ks

build:
	./bin/kaoscript -c -t ecma-v5 -o lib src/compiler.ks
	./bin/kaoscript -c -t ecma-v5 -o lib -r src/compiler.ks=lib/compiler.js src/bin.ks

test:
ifeq ($(g),)
	node_modules/.bin/mocha --colors --check-leaks --reporter spec
else
	node_modules/.bin/mocha --colors --check-leaks --reporter spec -g "$(g)"
endif

testks:
ifeq ($(g),)
	node_modules/.bin/mocha --colors --check-leaks --reporter spec --compilers ks:./register.js
else
	node_modules/.bin/mocha --colors --check-leaks --reporter spec --compilers ks:./register.js -g "$(g)"
endif

clean:
	find -L . -type f \( -name "*.ksb" -o -name "*.ksh" -o -name "*.ksm" \) -exec rm {} \;

ok:
	make clean
	make comp
	make comp
	make comp
	make testks

.PHONY: test build bin comp