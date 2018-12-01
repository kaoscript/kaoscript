require("kaoscript/register");
var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	var {foo, MyError} = require("../export/export.throw.intern.we.ks")();
	try {
		foo();
	}
	catch(__ks_0) {
		if(Type.is(__ks_0, MyError)) {
			let error = __ks_0;
			console.error(error);
		}
	}
};