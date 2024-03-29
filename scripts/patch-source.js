var Compiler = require('../lib/compiler.js')().Compiler;
var fs = require('fs');
var klaw = require('klaw-sync');
var path = require('path');
var program = require('commander');

program.parse(process.argv);

var filter = function(item) {
	return item.path.slice(-3) === '.js'
}

if(program.args.length === 1) {
	var directory = program.args[0];

	filter = function(item) {
		return item.path.slice(-3) === '.js' && path.basename(path.dirname(item.path)) === directory
	}
}
else if(program.args.length === 2) {
	var directory = program.args[0];
	var basename = program.args[1];

	filter = function(item) {
		return item.path.slice(-3) === '.js' && path.basename(path.dirname(item.path)) === directory && path.basename(item.path).startsWith(basename)
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
		var compiler = new Compiler(path.join(root, name + '.ks'), {
			header: false
		});

		var data = compiler.compile().toSource();

		fs.writeFileSync(path.join(root, name + '.js'), data, {
			encoding: 'utf8'
		});
	}
	catch(error) {
	}
}
