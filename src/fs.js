/**
 * fs.js
 * Version 0.1.0
 * September 14th, 2016
 *
 * Copyright (c) 2016 Baptiste Augrain
 * Licensed under the MIT license.
 * http://www.opensource.org/licenses/mit-license.php
 **/
var constants = require('constants');
var crypto = require('crypto');
var fs = require('fs');
var path = require('path');

module.exports = {
	exists: function(file) { // {{{
		try {
			fs.accessSync(file);
			
			return true;
		}
		catch(error) {
			try {
				fs.lstatSync(file);
				
				return true;
			}
			catch(error) {
				return false;
			}
		}
	}, // }}}
	hidden: function(file, ext) { // {{{
		return path.join(path.dirname(file), '.' + path.basename(file) + ext)
	}, // }}}
	isFile: function(file) { // {{{
		file = path.resolve(this.resolve(file));
		
		if(!this.exists(file)) {
			return false;
		}
		
		try {
			var stats = fs.statSync(file);
			var type = stats.mode & constants.S_IFMT;
			
			return type == constants.S_IFREG;
		}
		catch(error) {
			return false;
		}
	}, // }}}
	readFile: function(file) { // {{{
		return fs.readFileSync(file, {
			encoding: 'utf8'
		});
	}, // }}}
	resolve: function(file) { // {{{
		if(!((process.platform === 'win32' && /^[a-zA-Z]:/.test(file)) || (process.platform !== 'win32' && file[0] === '/'))) {
			Array.prototype.unshift.call(arguments, process.cwd());
		}
		
		return path.normalize(path.join.apply(null, arguments));
	}, // }}}
	sha256: function(data) { // {{{
		return crypto.createHash('sha256').update(data).digest('hex');
	}, // }}}
	writeFile: fs.writeFileSync
};