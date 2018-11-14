var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	const __ks_reverse_1 = reverse;
	function reverse() {
		if(arguments.length === 1) {
			let __ks_i = -1;
			let value = arguments[++__ks_i];
			if(value === void 0 || value === null) {
				return __ks_reverse_1(...arguments);
			}
			else if(!Type.isString(value)) {
				return __ks_reverse_1(...arguments);
			}
			return value.split("").reverse().join("");
		}
		else {
			return __ks_reverse_1(...arguments);
		}
	};
	return {
		reverse: reverse
	};
};