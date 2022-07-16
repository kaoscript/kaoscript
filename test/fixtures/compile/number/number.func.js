const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function ratio() {
		return ratio.__ks_rt(this, arguments);
	};
	ratio.__ks_0 = function(min, max) {
		return ((min + max) / 2).round(2);
	};
	ratio.__ks_rt = function(that, args) {
		const t0 = Type.isNumber;
		if(args.length === 2) {
			if(t0(args[0]) && t0(args[1])) {
				return ratio.__ks_0.call(that, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	};
};