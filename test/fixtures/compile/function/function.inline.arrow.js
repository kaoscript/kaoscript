const {Helper, Operator, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function camelize() {
		return camelize.__ks_rt(this, arguments);
	};
	camelize.__ks_0 = function(value) {
		return Operator.add(value.charAt(0).toLowerCase(), value.substring(1).replace(/[-_\s]+(.)/g, Helper.function((m, l) => {
			return l.toUpperCase();
		}, (fn, ...args) => {
			const t0 = Type.isValue;
			if(args.length === 2) {
				if(t0(args[0]) && t0(args[1])) {
					return fn.call(null, args[0], args[1]);
				}
			}
			throw Helper.badArgs();
		})));
	};
	camelize.__ks_rt = function(that, args) {
		const t0 = Type.isString;
		if(args.length === 1) {
			if(t0(args[0])) {
				return camelize.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};