require("kaoscript/register");
var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	var {foo, __ks_SyntaxError} = require("../export/export.throw.extern.we.default.ks")();
	try {
		foo();
	}
	catch(__ks_0) {
		if(Type.isClassInstance(__ks_0, SyntaxError)) {
			let error = __ks_0;
			console.error(error);
		}
	}
};