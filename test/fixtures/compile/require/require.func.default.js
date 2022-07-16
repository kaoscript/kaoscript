const {Type} = require("@kaoscript/runtime");
module.exports = function(reverse) {
	reverse.__ks_1 = function(value) {
		return -value;
	};
	reverse.__ks_rt = function(that, args) {
		const t0 = Type.isNumber;
		if(args.length === 1) {
			if(t0(args[0])) {
				return reverse.__ks_1.call(that, args[0]);
			}
			return reverse.__ks_0.call(that, Array.from(args));
		}
		return reverse.__ks_0.call(that, Array.from(args));
	};
	return {
		reverse
	};
};