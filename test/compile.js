var chai = require('chai');
var Compiler = require('../build/compiler.js')().Compiler;
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
			
			var compiler = new Compiler(path.join(__dirname, 'fixtures', 'compile', file));
			
			try {
				var error = fs.readFileSync(path.join(__dirname, 'fixtures', 'compile', name + '.error'), {
					encoding: 'utf8'
				});
			}
			catch(error) {
			}
			
			if(error) {
				expect(function() {
					compiler.compile().toSource();
				}).to.throw(error);
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
					var data = compiler.toMetadata();
					//console.log(JSON.stringify(data, null, 2))
					
					expect(data).to.eql(JSON.parse(metadata, function(key, value) {
						return value === "Infinity"? Infinity : value;
					}));
				}
			}
		});
	}
});