var Compiler = require('./lib/compiler.js')().Compiler;
var fs = require('fs');
var path = require('path');
var program = require("commander");

program.parse(process.argv);

var files = fs.readdirSync(path.join(__dirname, 'test', 'fixtures', 'compile'));
var prefix = program.args[0]
var preLength = prefix.length

var file;
for(var i = 0; i < files.length; i++) {
	file = files[i];
	
	if(file.slice(-3) === '.js' && file.substr(0, preLength) === prefix) {
		patch(file);
	}
}
	
function patch(file) {
	var name = file.slice(0, -3);
	
	console.log('patching ./' + path.join('test', 'fixtures', 'compile', name + '.ks'))
	
	try {
		var compiler = new Compiler(path.join(__dirname, 'test', 'fixtures', 'compile', name + '.ks'), {
			config: {
				header: false
			}
		});
		
		var data = compiler.compile().toSource();
		
		fs.writeFileSync(path.join(__dirname, 'test', 'fixtures', 'compile', name + '.js'), data, {
			encoding: 'utf8'
		});
	}
	catch(error) {
	}
}