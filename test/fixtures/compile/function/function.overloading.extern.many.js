const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	reverse.__ks_2 = function(value) {
		return value.split("").reverse().join("");
	};
	reverse.__ks_rt = function(that, args) {
		const t0 = Type.isArray;
		const t1 = Type.isNumber;
		const t2 = Type.isString;
		if(args.length === 1) {
			if(t0(args[0])) {
				return reverse.__ks_0.call(that, args[0]);
			}
			if(t1(args[0])) {
				return reverse.__ks_0.call(that, args[0]);
			}
			if(t2(args[0])) {
				return reverse.__ks_2.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	return {
		reverse
	};
};