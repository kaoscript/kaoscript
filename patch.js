var Compiler = require('./build/compiler.js')().Compiler;
var fs = require('fs');
var path = require('path');

var files = fs.readdirSync(path.join(__dirname, 'test', 'fixtures', 'compile'));

var file;
for(var i = 0; i < files.length; i++) {
	file = files[i];
	
	if(file.slice(-3) === '.ks') {
		prepare(file);
	}
}
	
function prepare(file) {
	var name = file.slice(0, -3);
	
	try {
		fs.readFileSync(path.join(__dirname, 'test', 'fixtures', 'compile', name + '.json'), {
			encoding: 'utf8'
		});
		
		var compiler = new Compiler(path.join(__dirname, 'test', 'fixtures', 'compile', file), {
			config: {
				header: false
			}
		});
		
		compiler.compile().toSource();
		
		var data = compiler.toMetadata();
		
		fs.writeFileSync(
			path.join(__dirname, 'test', 'fixtures', 'compile', name + '.json'),
			JSON.stringify(data, function(key, value) {
				if(value == Infinity) {
					return 'Infinity';
				}
				return value;
			}, 2),
			{
				encoding: 'utf8'
			}
		);
	}
	catch(error) {
	}
}