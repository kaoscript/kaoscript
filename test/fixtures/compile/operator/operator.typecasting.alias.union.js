const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function toNS() {
		return toNS.__ks_rt(this, arguments);
	};
	toNS.__ks_0 = function(x) {
		return Helper.cast(x, "NS", true, null, "Number", null, "String");
	};
	toNS.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return toNS.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};