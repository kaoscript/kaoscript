require("kaoscript/register");
var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	var foo = require("../export/export.throw.extern.ne.ks")().foo;
	try {
		foo();
	}
	catch(__ks_0) {
		if(Type.isInstance(__ks_0, SyntaxError)) {
			let error = __ks_0;
			console.error(error);
		}
	}
};