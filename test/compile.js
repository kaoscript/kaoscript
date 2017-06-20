var chai = require('chai');
var Compiler = require(process.env.running_under_istanbul ? '../src/compiler.ks' : '..')().Compiler;
var expect = require('chai').expect;
var fs = require('fs');
var path = require('path');

describe('compile', function() {
	var files = fs.readdirSync(path.join(__dirname, 'fixtures', 'compile'));
	
	var file;
	for(var i = 0; i < files.length; i++) {
		file = files[i];
		
		if(file.slice(-3) === '.ks') {
			prepare(file);
		}
	}
	
	function prepare(file) {
		var name = file.slice(0, -3);
		it(name, function() {
			this.timeout(5000);
			
			var compiler = new Compiler(path.join(__dirname, 'fixtures', 'compile', file), {
				config: {
					header: false
				}
			});
			
			try {
				var error = fs.readFileSync(path.join(__dirname, 'fixtures', 'compile', name + '.error'), {
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
					//console.log(ex)
					expect(ex.fileName).to.exist;
					
					ex.fileName = path.relative(__dirname, ex.fileName);
					
					expect(ex.toString()).to.equal(error);
				}
				
				expect(data).to.not.exist;
			}
			else {
				var data = compiler.compile().toSource();
				//console.log(data);
				
				expect(data).to.equal(fs.readFileSync(path.join(__dirname, 'fixtures', 'compile', name + '.js'), {
					encoding: 'utf8'
				}));
				
				try {
					var metadata = fs.readFileSync(path.join(__dirname, 'fixtures', 'compile', name + '.json'), {
						encoding: 'utf8'
					});
				}
				catch(error) {
				}
				
				if(metadata) {
					var data = JSON.stringify(compiler.toMetadata(), function(key, value){return value === Infinity ? 'Infinity' : value === true ? 'true' : value === false ? 'false' : value;}, 2);
					//console.log(data);
					
					expect(JSON.parse(data)).to.eql(JSON.parse(metadata));
				}
			}
		});
	}
});