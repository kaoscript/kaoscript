var fs = require('fs');
var metadata = require('../package.json');
var path = require('path');
var program = require('commander');

function getPackage(source) {
	var version = parseInt(/^v(\d+)\./.exec(process.version)[1]) >= 6 ? 'es6' : 'es5'

	if(source === 'github') {
		return 'compiler-bin-js-' + version;
	}
	else {
		return 'compiler-bin-' + version;
	}
}

program
	.command('dependency')
	.action(function() {
		if(metadata._requested && (metadata._requested.type === 'git' || metadata._requested.type === 'hosted')) {
			console.log('github:kaoscript/' + getPackage('github'));
		}
		else if(metadata._resolved && metadata._resolved.substr(0, 4) !== 'git:') {
			console.log('@kaoscript/' + getPackage() + '@^' + metadata.version.split('.').slice(0, 2).join('.'));
		}
		else {
			console.log('github:kaoscript/' + getPackage('github'));
		}
	});

program
	.command('binary')
	.action(function() {
		var data = fs.readFileSync(path.join(__dirname, '..', 'node_modules', '@kaoscript', getPackage(), 'compiler.js'));

		fs.writeFileSync(path.join(__dirname, '..', 'lib', 'compiler.js'), data);
	});

program.parse(process.argv);