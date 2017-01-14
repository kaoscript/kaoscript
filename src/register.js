/**
 * register.js
 * Version 0.7.2
 * September 14th, 2016
 *
 * Copyright (c) 2016 Baptiste Augrain
 * Licensed under the MIT license.
 * http://www.opensource.org/licenses/mit-license.php
 **/
var _ = require('..')();
var fs = require('./fs.js');
var path = require('path');

var Compiler = _.Compiler;
var target = parseInt(/^v(\d+)\./.exec(process.version)[1]) >= 6 ? 'ecma-v6' : 'ecma-v5';

var loadFile = function(module, filename) { // {{{
	try {
		var source = fs.readFile(filename);
		
		if(fs.isFile(_.getBinaryPath(filename, target)) && fs.isFile(_.getHashPath(filename, target)) && _.isUpToDate(filename, target, source)) {
			var data = fs.readFile(_.getBinaryPath(filename, target));
		}
		else {
			var options = {
				register: false,
				target: target
			};
			
			var root = path.join(__dirname, '..')
			if(!(filename.length > root.length && filename.substr(0, root.length) === root) && fs.exists(path.join(root, 'node_modules', '@kaoscript', 'runtime'))) {
				options.config = {
					runtime: {
						package: 'kaoscript/node_modules/@kaoscript/runtime'
					}
				};
			}
			
			var compiler = new Compiler(filename, options);
			
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
	require.extensions[_.extensions.source] = loadFile;
	
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