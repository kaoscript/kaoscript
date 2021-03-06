var Compiler = require('../lib/compiler.js')().Compiler;
var fs = require('fs');
var klaw = require('klaw-sync');
var path = require('path');
var program = require('commander');

program.parse(process.argv);

var filter = function(item) {
	return item.path.slice(-3) === '.js'
}

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

		var data = compiler.toMetadata();

		fs.writeFileSync(
			path.join(root, name + '.json'),
			JSON.stringify(data, function(key, value){return value === Infinity ? 'Infinity' : value;}, 2),
			{
				encoding: 'utf8'
			}
		);
	}
	catch(error) {
	}
}