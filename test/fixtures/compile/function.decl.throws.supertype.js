var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foo(bar) {
		if(bar === undefined || bar === null) {
			throw new Error("Missing parameter 'bar'");
		}
	}
	try {
		foo();
	}
	catch(__ks_0) {
		if(Type.is(__ks_0, Error) {
		}
	}
}