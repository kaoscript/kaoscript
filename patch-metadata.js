var Compiler = require('./lib/compiler.js')().Compiler;
var fs = require('fs');
var klaw = require('klaw-sync');
var path = require('path');

var files = klaw(path.join(__dirname, 'test', 'fixtures', 'compile'), {
	nodir: true,
	traverseAll: true,
	filter: function(item) {
		return item.path.slice(-3) === '.ks'
	}
});

for(var i = 0; i < files.length; i++) {
	patch(files[i].path)
}

function patch(file) {
	var root = path.dirname(file)
	var name = path.basename(file).slice(0, -3);
	
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