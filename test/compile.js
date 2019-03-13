var chai = require('chai');
var Compiler = require(process.env.running_under_istanbul ? '../src/compiler.ks' : '..')().Compiler;
var expect = require('chai').expect;
var fs = require('fs');
var klaw = require('klaw-sync');
var path = require('path');

require('@kaoscript/target-commons')(Compiler)

function replacer(key, value){
	if(value === undefined) {
		// return 'undefined'
		throw new Error('the value of "' + key + '" is not nullable');
	}

	return value === Infinity ? 'Infinity' : value;
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
		prepare(files[i].path)
	}

	function prepare(file) {
		var root = path.dirname(file)
		var name = path.basename(file).slice(0, -3);
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
					data = compiler.compile().toSource();
				}
				catch(ex) {
					// console.log(ex)
					expect(ex.fileName).to.exist;

					ex.fileName = path.relative(__dirname, ex.fileName);

					expect(ex.toString()).to.equal(error);
				}

				expect(data).to.not.exist;
			}
			else {
				var data = compiler.compile().toSource();
				// console.log(data);

				expect(data).to.equal(fs.readFileSync(path.join(root, name + '.js'), {
					encoding: 'utf8'
				}));

				try {
					var metadata = fs.readFileSync(path.join(root, name + '.json'), {
						encoding: 'utf8'
					});
				}
				catch(error) {
				}

				if(metadata) {
					var data = JSON.stringify(compiler.toMetadata(), replacer, 2);
					// console.log(data);

					expect(JSON.parse(data)).to.eql(JSON.parse(metadata));
				}
			}
		});
	}
});