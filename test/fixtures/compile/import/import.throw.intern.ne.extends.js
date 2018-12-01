require("kaoscript/register");
var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	var __ks_SyntaxError = {};
	var foo = require("../export/export.throw.intern.ne.extends.ks")().foo;
	try {
		foo();
	}
	catch(__ks_0) {
		if(Type.is(__ks_0, SyntaxError)) {
			let error = __ks_0;
			console.error(error);
		}
	}
};