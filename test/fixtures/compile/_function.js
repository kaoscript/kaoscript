module.exports = function(Helper, Type) {
	var __ks_Function = {};
	__ks_Function.__ks_sttc_vcurry_0 = function(self, bind = null, ...args) {
		if(arguments.length < 1) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(self === void 0 || self === null) {
			throw new TypeError("'self' is not nullable");
		}
		else if(!Type.isFunction(self)) {
			throw new TypeError("'self' is not of type 'Function'");
		}
		return function(...additionals) {
			return self.apply(bind, args.concat(additionals));
		};
	};
	__ks_Function._cm_vcurry = function() {
		var args = Array.prototype.slice.call(arguments);
		return __ks_Function.__ks_sttc_vcurry_0.apply(null, args);
	};
	return {
		Function: Function,
		__ks_Function: __ks_Function
	};
};