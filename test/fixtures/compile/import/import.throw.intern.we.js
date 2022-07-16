require("kaoscript/register");
const {Type} = require("@kaoscript/runtime");
module.exports = function() {
	var {foo, MyError} = require("../export/.export.throw.intern.we.ks.j5k8r9.ksb")();
	try {
		foo.__ks_0();
	}
	catch(__ks_0) {
		if(Type.isClassInstance(__ks_0, MyError)) {
			let error = __ks_0;
			console.error(error);
		}
	}
};