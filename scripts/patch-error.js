var Compiler = require('../lib/compiler.js')().Compiler;
var fs = require('fs');
var klaw = require('klaw-sync');
var path = require('path');
var program = require('commander');

program.parse(process.argv);

var filter = function(item) {
	return item.path.slice(-6) === '.error'
}

if (program.args.length > 0) {
	var directory = program.args[0];

	filter = function(item) {
		return item.path.slice(-6) === '.error' && path.basename(path.dirname(item.path)) === directory
	}
}

var testDirPath = path.join(__dirname, '..', 'test');

var files = klaw(path.join(testDirPath, 'fixtures', 'compile'), {
	nodir: true,
	traverseAll: true,
	filter: filter
});

for(var i = 0; i < files.length; i++) {
	patch(files[i].path)
}

function patch(file) {
	var root = path.dirname(file)
	var name = path.basename(file).slice(0, -6);

	console.log('patching ' + name + '.ks')

	var data;

	try {
		var compiler = new Compiler(path.join(root, name + '.ks'), {
			header: false
		});

		data = compiler.compile().toSource();
	}
	catch(ex) {
		if(ex.fileName) {
			ex.fileName = path.relative(testDirPath, ex.fileName);

			fs.writeFileSync(path.join(root, name + '.error'), ex.toString(), {
				encoding: 'utf8'
			});
		}
	}
}