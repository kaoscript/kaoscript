var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	var __ks_Array = {};
	__ks_Array.__ks_sttc_merge_0 = function(...args) {
		var source;
		var i = 0;
		var l = args.length;
		while((i < l) && !((Type.isValue(args[i]) ? (source = args[i], true) : false) && Type.isArray(source))) {
			++i;
		}
		++i;
		while(i < l) {
			if(Type.isArray(args[i])) {
				for(var __ks_0 = 0, __ks_1 = args[i].length, value; __ks_0 < __ks_1; ++__ks_0) {
					value = args[i][__ks_0];
					source.pushUniq(value);
				}
			}
			++i;
		}
		return source;
	};
	__ks_Array._cm_merge = function() {
		var args = Array.prototype.slice.call(arguments);
		return __ks_Array.__ks_sttc_merge_0.apply(null, args);
	};
};