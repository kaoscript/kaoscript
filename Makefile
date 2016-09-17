comp:
	./bin/kaoscript -c -o build src/compiler.ks

build:
	./bin/kaoscript -c -o build src/compiler.ks
	./bin/kaoscript -c -o build -r src/compiler.ks=build/compiler.js src/bin.ks

test:
ifeq ($(g),)
	node_modules/.bin/mocha --colors --reporter spec
else
	node_modules/.bin/mocha --colors --reporter spec -g "$(g)"
endif

testks:
ifeq ($(g),)
	node_modules/.bin/mocha --colors --reporter spec --compilers ks:./register.js -g ""
else
	node_modules/.bin/mocha --colors --reporter spec --compilers ks:./register.js -g "$(g)"
endif

clean:
	find . -type f \( -name "*.ksb" -o -name "*.ksh" -o -name "*.ksm" \) -delete

.PHONY: test build