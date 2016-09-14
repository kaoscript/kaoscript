comp:
	node compile.js

test:
ifeq ($(g),)
	node_modules/.bin/mocha --colors --reporter spec
else
	node_modules/.bin/mocha --colors --reporter spec -g "$(g)"
endif

testks:
ifeq ($(g),)
	node_modules/.bin/mocha --colors --reporter spec --compilers ks:./src/register.js -g ""
else
	node_modules/.bin/mocha --colors --reporter spec --compilers ks:./src/register.js -g "$(g)"
endif

clean:
	find ./src -type f \( -name "*.ksb" -o -name "*.ksh" -o -name "*.ksm" \) -delete
	find ./test -type f \( -name "*.ksb" -o -name "*.ksh" -o -name "*.ksm" \) -delete

.PHONY: test