const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(values) {
		if(values === void 0) {
			values = null;
		}
		if(Type.isValue(values)) {
		}
		else {
			for(let __ks_1 = 0, __ks_0 = Helper.length(values), value; __ks_1 < __ks_0; ++__ks_1) {
				value = values[__ks_1];
			}
		}
	};
	foobar.__ks_rt = function(that, args) {
		if(args.length === 1) {
			return foobar.__ks_0.call(that, args[0]);
		}
		throw Helper.badArgs();
	};
};