var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	const __ks_foobar_1 = foobar;
	function foobar() {
		if(arguments.length === 1 && Type.isNumber(arguments[0])) {
			let __ks_i = -1;
			let a = arguments[++__ks_i];
			if(a === void 0 || a === null) {
				return __ks_foobar_1(...arguments);
			}
			else if(!Type.isNumber(a)) {
				return __ks_foobar_1(...arguments);
			}
			return 1;
		}
		else if(arguments.length === 2 && Type.isNumber(arguments[0]) && Type.isNumber(arguments[1])) {
			let __ks_i = -1;
			let a = arguments[++__ks_i];
			if(a === void 0 || a === null) {
				return __ks_foobar_1(...arguments);
			}
			else if(!Type.isNumber(a)) {
				return __ks_foobar_1(...arguments);
			}
			let b = arguments[++__ks_i];
			if(b === void 0 || b === null) {
				return __ks_foobar_1(...arguments);
			}
			else if(!Type.isNumber(b)) {
				return __ks_foobar_1(...arguments);
			}
			return 1;
		}
		else {
			return __ks_foobar_1(...arguments);
		}
	};
};