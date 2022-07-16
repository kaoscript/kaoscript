const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function blend() {
		return blend.__ks_rt(this, arguments);
	};
	blend.__ks_0 = function(x, y, percentage) {
		return ((1 - percentage) * x) + (percentage * y);
	};
	blend.__ks_rt = function(that, args) {
		const t0 = Type.isNumber;
		if(args.length === 3) {
			if(t0(args[0]) && t0(args[1]) && t0(args[2])) {
				return blend.__ks_0.call(that, args[0], args[1], args[2]);
			}
		}
		throw Helper.badArgs();
	};
};