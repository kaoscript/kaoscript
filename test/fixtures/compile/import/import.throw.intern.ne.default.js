require("kaoscript/register");
var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	var foo = require("../export/export.throw.intern.ne.default.ks")().foo;
	try {
		foo();
	}
	catch(__ks_0) {
		if(Type.isClassInstance(__ks_0, Error)) {
			let error = __ks_0;
			console.error(error);
		}
	}
};