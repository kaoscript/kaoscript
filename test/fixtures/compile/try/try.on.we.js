const {Type} = require("@kaoscript/runtime");
module.exports = function() {
	try {
		console.log("foobar");
	}
	catch(__ks_0) {
		if(Type.isClassInstance(__ks_0, RangeError)) {
			let error = __ks_0;
			console.log("RangeError", error);
		}
		else {
			let error = __ks_0;
			console.log("Error", error);
		}
	}
};