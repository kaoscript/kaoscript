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
				for(var value in args[i]) {
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
}