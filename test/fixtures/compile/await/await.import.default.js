require("kaoscript/register");
var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	var foo = require("../async/async.export.default.ks")().foo;
	function bar(__ks_cb) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 0 + 1)");
		}
		else if(!Type.isFunction(__ks_cb)) {
			throw new TypeError("'callback' must be a function");
		}
		foo(42, (__ks_e, __ks_0) => {
			if(__ks_e) {
				__ks_cb(__ks_e);
			}
			else {
				return __ks_cb(null, __ks_0);
			}
		});
	}
};