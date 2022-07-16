const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function equals() {
		return equals.__ks_rt(this, arguments);
	};
	equals.__ks_0 = function(itemA, itemB) {
		return Object.equals(itemA, itemB);
	};
	equals.__ks_rt = function(that, args) {
		const t0 = Type.isObject;
		if(args.length === 2) {
			if(t0(args[0]) && t0(args[1])) {
				return equals.__ks_0.call(that, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	};
};