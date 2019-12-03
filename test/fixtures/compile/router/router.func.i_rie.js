var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foobar() {
		if(arguments.length === 1) {
			let __ks_i = -1;
			let x = arguments[++__ks_i];
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
			else if(!Type.isNumber(x)) {
				throw new TypeError("'x' is not of type 'Number'");
			}
			return x;
		}
		else {
			let __ks_i = -1;
			let values = [];
			while(arguments.length > ++__ks_i) {
				if(Type.isNumber(arguments[__ks_i])) {
					values.push(arguments[__ks_i]);
				}
				else {
					throw new TypeError("'values' is not of type 'Number'");
				}
			}
			return -1;
		}
	};
};