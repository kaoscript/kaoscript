var fs = require('fs');
var https = require('https');
var metadata = require('../package.json');
var path = require('path');

var file = path.join(__dirname, '..', 'lib', 'compiler.js');
var url = 'https://raw.githubusercontent.com/kaoscript/compiler-bin-js-es6/v' + metadata.version + '/compiler.js';

https.get(url, function(response) {
	var stream = fs.createWriteStream(file);

	response.pipe(stream);

	stream.on('finish', function() {
		stream.close();
	});
}).on('error', function(error) {
	fs.unlink(file);

	throw error;
});
