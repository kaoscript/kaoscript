var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foo(bar, qux, __ks_cb) {
		if(bar === undefined || bar === null) {
			throw new Error("Missing parameter 'bar'");
		}
		else if(!Type.isString(bar)) {
			throw new Error("Invalid type for parameter 'bar'");
		}
		if(qux === undefined || qux === null) {
			throw new Error("Missing parameter 'qux'");
		}
		else if(!Type.isNumber(qux)) {
			throw new Error("Invalid type for parameter 'qux'");
		}
		if(!Type.isFunction(__ks_cb)) {
			throw new Error("Invalid callback");
		}
	}
}