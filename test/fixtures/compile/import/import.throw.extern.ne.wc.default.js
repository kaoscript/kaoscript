require("kaoscript/register");
module.exports = function() {
	var foo = require("../export/export.throw.extern.ne.ks")().foo;
	try {
		foo();
	}
	catch(error) {
		console.error(error);
	}
};