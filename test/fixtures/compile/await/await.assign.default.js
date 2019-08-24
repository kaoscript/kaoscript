var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	var fs = require("fs");
	function read(__ks_cb) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 0 + 1)");
		}
		else if(!Type.isFunction(__ks_cb)) {
			throw new TypeError("'callback' must be a function");
		}
		fs.readFile("data.json", (__ks_e, __ks_0) => {
			if(__ks_e) {
				__ks_cb(__ks_e);
			}
			else {
				let data = __ks_0;
				console.log(data);
				return __ks_cb(null, data);
			}
		});
	}
};