const Mocha = require('mocha')
const myArgs = process.argv.slice(2)

const success = []
const errors = []

const mocha = new Mocha({ reporter: function() {} })
mocha.checkLeaks()
mocha.addFile('./test/compile.test.js')
mocha.grep(myArgs[0])

mocha
	.run()
	.on('pass', (test) => {
		success.push(test.title)

		logSuccess(test.title)
	})
	.on('fail', (test, error) => {
		errors.push({test, error})

		if(!String(error).startsWith('AssertionError:')) {
			console.error(error.stack)
		}

		logError(test.title)
	})
	.on('end', () => {
		console.log()

		if(success.length > 0) {
			logSuccess(success.length + ' tests passed')
		}

		if(errors.length > 0) {
			logError(errors.length + ' tests failed')
		}
	})

function logSuccess(str) {
	console.log('\u001b[32m  ✓ \u001b[0m\u001b[90m' + str + '\u001b[0m')
}
function logError(str) {
	console.log('\u001b[31m  ✖ ' + str + '\u001b[0m')
}
