var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	try {
		console.log("foobar");
	}
	catch(__ks_0) {
		if(Type.is(__ks_0, RangeError)) {
			console.log("RangeError");
		}
		else {
			console.log("Error");
		}
	}
};