const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function(__ks_String) {
	if(!Type.isValue(__ks_String)) {
		__ks_String = {};
	}
	__ks_String.__ks_func_camelize_0 = function() {
		return this.replace(/[-_\s]+(.)/g, (() => {
			const __ks_rt = (...args) => {
				const t0 = Type.isValue;
				if(args.length === 2) {
					if(t0(args[0]) && t0(args[1])) {
						return __ks_rt.__ks_0.call(this, args[0], args[1]);
					}
				}
				throw Helper.badArgs();
			};
			__ks_rt.__ks_0 = (m, l) => {
				return l.toUpperCase();
			};
			return __ks_rt;
		})());
	};
	__ks_String._im_camelize = function(that, ...args) {
		return __ks_String.__ks_func_camelize_rt(that, args);
	};
	__ks_String.__ks_func_camelize_rt = function(that, args) {
		if(args.length === 0) {
			return __ks_String.__ks_func_camelize_0.call(that);
		}
		throw Helper.badArgs();
	};
};