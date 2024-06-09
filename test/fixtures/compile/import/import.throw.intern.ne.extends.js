require("kaoscript/register");
const {Type} = require("@kaoscript/runtime");
module.exports = function() {
	var foo = require("../export/.export.throw.intern.ne.extends.ks.j5k8r9.ksb")().foo;
	try {
		foo.__ks_0();
	}
	catch(__ks_0) {
		if(Type.isClassInstance(__ks_0, EvalError)) {
			let error = __ks_0;
			console.error(error);
		}
	}
};