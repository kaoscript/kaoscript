var chai = require('chai');
var expect = require('chai').expect;
var fs = require('fs');
var path = require('path');
var rimraf = require('rimraf');
var rt = require('@kaoscript/runtime');

require('../register');

describe('evaluate', function() {
	before(function(done) {
		rimraf(path.join(__dirname, 'fixtures', 'evaluate', '*.{ksb,ksh,ksm}'), done);
	});
	
	var files = fs.readdirSync(path.join(__dirname, 'fixtures', 'evaluate'));
	
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
			
			require(path.join(__dirname, 'fixtures', 'evaluate', file))(expect, rt.Helper, rt.Type);
		});
	}
	
	after(function(done) {
		rimraf(path.join(__dirname, 'fixtures', 'evaluate', '*.{ksb,ksh,ksm}'), done);
	});
});