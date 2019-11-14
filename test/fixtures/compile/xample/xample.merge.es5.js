var {Operator, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Array = {};
	__ks_Array.__ks_sttc_merge_0 = function(...args) {
		var i = 0;
		var l = args.length;
		while(Operator.lt(i, l) && !Type.isArray(args[i])) {
			++i;
		}
		if(Operator.lt(i, l)) {
			var source = args[i];
			while(Operator.lt(++i, l)) {
				if(Type.isArray(args[i])) {
					for(var __ks_0 = 0, __ks_1 = args[i].length, value; __ks_0 < __ks_1; ++__ks_0) {
						value = args[i][__ks_0];
						source.pushUniq(value);
					}
				}
			}
			return source;
		}
		else {
			return [];
		}
	};
	__ks_Array._cm_merge = function() {
		var args = Array.prototype.slice.call(arguments);
		return __ks_Array.__ks_sttc_merge_0.apply(null, args);
	};
};