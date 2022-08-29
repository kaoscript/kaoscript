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
var target = {
	name: 'v8',
	version: process.versions.v8.split('.').slice(0, 2).join('.')
};
var variationId = fs.djb2a(target.name + ',' + target.version);

var loadFile = function(module, filename) { // {{{
	var source = fs.readFile(filename);
	var binary = _.getBinaryPath(filename, variationId);

	if(fs.isFile(binary) && fs.isFile(_.getHashPath(filename)) && _.isUpToDate(filename, variationId, source)) {
		var data = fs.readFile(binary);
	}
	else {
		var options = {
			register: false,
			target: target
		};

		var root = path.join(__dirname, '..')
		if(!(filename.length > root.length && filename.substr(0, root.length) === root) && fs.exists(path.join(root, 'node_modules', '@kaoscript', 'runtime'))) {
			options.runtime = {
				helper: {
					package: 'kaoscript/node_modules/@kaoscript/runtime'
				},
				type: {
					package: 'kaoscript/node_modules/@kaoscript/runtime'
				}
			};
		}

		var compiler = new Compiler(filename, options);

		try {
			compiler.compile(source);
		}
		catch(error) {
			console.error(error.toString());

			throw error;
		}

		compiler.writeFiles();

		var data = compiler.toSource();
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
