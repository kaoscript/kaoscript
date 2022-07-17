var Compiler = require(process.env.running_under_istanbul ? '../src/compiler.ks' : '..')().Compiler;
var escapeJSON = require('../src/fs.js').escapeJSON
var expect = require('chai').expect;
var fs = require('fs');
var klaw = require('klaw-sync');
var path = require('path');

var debug = process.env.DEBUG === '1' || process.env.DEBUG === 'true' || process.env.DEBUG === 'on';
var testXArgs = !(process.env.XARGS === '0' || process.env.XARGS === 'false' || process.env.XARGS === 'off');

require('@kaoscript/target-commons')(Compiler)

var testings = [];
if(process.argv[1].endsWith('/test/compile.dev.js') && process.argv.length > 2) {
	var args = process.argv[2].split(' ');
	if(args[0] === 'compile' && !args[1].includes('|') && !args[1].includes('[')) {
		testings = args.slice(1);
	}
}

describe('compile', function() {
	var files = klaw(path.join(__dirname, 'fixtures', 'compile'), {
		nodir: true,
		traverseAll: true,
		filter: function(item) {
			return item.path.slice(-3) === '.ks'
		}
	});

	for(var i = 0; i < files.length; i++) {
		prepare(files[i].path);
	}

	function doit(file, root, name, args) { // {{{
		it(name, function() {
			this.timeout(5000);

			var compiler = new Compiler(file, {
				header: false
			});

			try {
				var error = fs.readFileSync(path.join(root, name + '.error'), {
					encoding: 'utf8'
				});
			}
			catch(error) {
			}

			if(error) {
				var data;

				try {
					compiler.initiate();

					args && compiler.setArguments(args);

					data = compiler.finish().toSource();
				}
				catch(ex) {
					if(debug && !ex.fileName) {
						console.log(ex);
					}

					expect(ex.fileName).to.exist;

					ex.fileName = path.relative(__dirname, ex.fileName);

					try {
						expect(ex.toString()).to.equal(error);
					}
					catch(ex2) {
						if(debug) {
							console.log(ex.toString());
						}

						throw ex2;
					}
				}

				if(data && debug) {
					console.log(data);
					console.log('>----------------------------------------------------------<');
					console.log('It should throw an error');
				}

				expect(data).to.not.exist;
			}
			else {
				compiler.initiate();

				args && compiler.setArguments(args);

				var data = compiler.finish().toSource();

				try {
					expect(data).to.equal(fs.readFileSync(path.join(root, name + '.js'), {
						encoding: 'utf8'
					}));
				}
				catch(ex) {
					if(debug) {
						console.log(data);
					}

					throw ex;
				}

				try {
					var metadata = fs.readFileSync(path.join(root, name + '.json'), {
						encoding: 'utf8'
					});
				}
				catch(error) {
				}

				if(metadata) {
					var data = JSON.stringify([compiler.toRequirements(), compiler.toExports()], escapeJSON, 2);

					try {
						expect(JSON.parse(data)).to.eql(JSON.parse(metadata));
					}
					catch(ex) {
						if(debug) {
							console.log(data);
						}

						throw ex;
					}

					metadata = null;
				}
			}
		});
	} // }}}

	function prepare(file) { // {{{
		var root = path.dirname(file)
		var name = path.basename(file).slice(0, -3);

		if(testings.length > 0 && !testings.some((testing) => name.startsWith(testing) || testing.startsWith(name))) {
			return;
		}

		try {
			var args = fs.readFileSync(path.join(root, name + '.args'), {
				encoding: 'utf8'
			});
		}
		catch(error) {
		}

		if(args) {
			if(!testXArgs) {
				return;
			}

			args = JSON.parse(args);

			var compiler = new Compiler(file, {
				header: false
			});

			compiler.initiate();

			var scope = compiler.module().scope()
			var metaReqs = compiler.toRequirements();

			for(var i = 0; i < args.length; i++) {
				if(args[i]) {
					var argz = [];

					for(var k = 0; k < args[i].length; k++) {
						argz.push(args[i][k] ? {
							name: k,
							type: scope.getVariable(metaReqs.requirements[(k * 3) + 1]).getRealType()
						} : null);
					}

					doit(file, root, name + '.' + i, argz)
				}
				else {
					doit(file, root, name + '.' + i)
				}
			}
		}
		else {
			doit(file, root, name)
		}
	} // }}}
});
