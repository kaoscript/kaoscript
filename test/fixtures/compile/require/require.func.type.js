var Type = require("@kaoscript/runtime").Type;
module.exports = function(reverse) {
	const __ks_reverse_1 = reverse;
	function reverse() {
		if(arguments.length === 1 && Type.isNumber(arguments[0])) {
			let __ks_i = -1;
			let value = arguments[++__ks_i];
			if(value === void 0 || value === null) {
				return __ks_reverse_1(...arguments);
			}
			else if(!Type.isNumber(value)) {
				return __ks_reverse_1(...arguments);
			}
			return -value;
		}
		else {
			return __ks_reverse_1(...arguments);
		}
	};
	return {
		reverse: reverse
	};
};