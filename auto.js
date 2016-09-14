var Compiler = require('./build/compiler.js')().Compiler;
var path = require('path');

var compiler = new Compiler(path.join(__dirname, 'src', 'compiler.ks'), {
	output: path.join(__dirname, 'build', 'compiler.js')
});

compiler.compile().writeOutput();