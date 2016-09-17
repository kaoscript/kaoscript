var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	try {
		console.log("foobar");
	}
	catch(__ks_0) {
		if(Type.is(__ks_0, RangeError) {
			let error = __ks_0;
			console.log("RangeError", error);
		}
		else {
			let error = __ks_0;
			console.log("Error", error);
		}
	}
}