const {Type} = require("@kaoscript/runtime");
module.exports = function() {
	try {
		console.log("foobar");
	}
	catch(__ks_0) {
		if(Type.isClassInstance(__ks_0, RangeError)) {
			console.log("RangeError");
		}
		else {
			console.log("Error");
		}
	}
};