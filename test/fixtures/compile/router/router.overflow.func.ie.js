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
		else {
			return __ks_foobar_1(...arguments);
		}
	};
};