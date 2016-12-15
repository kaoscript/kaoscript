/**
 * register.js
 * Version 0.1.0
 * September 14th, 2016
 *
 * Copyright (c) 2016 Baptiste Augrain
 * Licensed under the MIT license.
 * http://www.opensource.org/licenses/mit-license.php
 **/
var {Compiler, extensions, isUpToDate} = require('../build/compiler.js')();
var fs = require('./fs.js');
var path = require('path');

var loadFile = function(module, filename) { // {{{
	try {
		var source = fs.readFile(filename);
		
		if(fs.isFile(fs.hidden(filename, extensions.binary)) && fs.isFile(fs.hidden(filename, extensions.hash)) && isUpToDate(filename, source)) {
			var data = fs.readFile(fs.hidden(filename, extensions.binary));
		}
		else {
			var compiler = new Compiler(filename, {
				register: false
			});
			
			compiler.compile(source);
			
			compiler.writeFiles();
			
			var data = compiler.toSource();
		}
	}
	catch(error) {
		if(!error.message.startsWith('/')) {
			error.message = (error.filename || filename) + ': '+ error.message;
		}
		
		throw error;
	}
	
	return module._compile(data, filename);
}; // }}}

if(require.extensions) {
	require.extensions[extensions.source] = loadFile;
	
	var Module = require('module');
	var findExtension = function(filename) { // {{{
		var extensions = path.basename(filename).split('.');
		if(extensions[0] === '') {
			extensions.shift();
		}
		
		var curExtension;
		while(extensions.shift()) {
			curExtension = '.' + extensions.join('.');
			
			if(Module._extensions[curExtension]) {
				return curExtension;
			}
		}
		
		return '.js';
	}; // }}}
	
	Module.prototype.load = function(filename) { // {{{
		this.filename = filename;
		this.paths = Module._nodeModulePaths(path.dirname(filename));
		
		Module._extensions[findExtension(filename)](this, filename);
		
		return this.loaded = true;
	}; // }}}
}