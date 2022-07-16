var Compiler = require('../lib/compiler.js')().Compiler;
var escapeJSON = require('../src/fs.js').escapeJSON
var fs = require('fs');
var klaw = require('klaw-sync');
var path = require('path');
var program = require('commander');

program.parse(process.argv);

function filter(item) { // {{{
	return item.path.slice(-3) === '.js'
} // }}}

/* function replacer(key, value) { // {{{
	if(value === undefined) {
		throw new Error('the value of "' + key + '" is not nullable');
	}

	return value === Infinity ? 'Infinity' : value;
} // }}} */

if (program.args.length > 0) {
	var directory = program.args[0];

	filter = function(item) {
		return item.path.slice(-3) === '.js' && path.basename(path.dirname(item.path)) === directory
	}
}

var files = klaw(path.join(__dirname, '..', 'test', 'fixtures', 'compile'), {
	nodir: true,
	traverseAll: true,
	filter: filter
});

for(var i = 0; i < files.length; i++) {
	patch(files[i].path)
}

function patch(file) {
	var root = path.dirname(file)
	var name = path.basename(file).slice(0, -3);

	console.log('patching ' + name + '.ks')

	try {
		fs.readFileSync(path.join(root, name + '.json'), {
			encoding: 'utf8'
		});

		var compiler = new Compiler(path.join(root, name + '.ks'), {
			config: {
				header: false
			}
		});

		compiler.compile().toSource();

		var data = JSON.stringify([compiler.toRequirements(), compiler.toExports()], escapeJSON, 2);

		fs.writeFileSync(
			path.join(root, name + '.json'),
			data,
			{
				encoding: 'utf8'
			}
		);
	}
	catch(error) {
	}
}
