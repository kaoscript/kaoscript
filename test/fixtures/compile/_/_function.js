var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	var __ks_Function = {};
	__ks_Function.__ks_sttc_vcurry_0 = function(self, bind = null, ...args) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
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
	__ks_Function.__ks_func_toSource_0 = function() {
		return this.toString();
	};
	__ks_Function._cm_vcurry = function() {
		var args = Array.prototype.slice.call(arguments);
		return __ks_Function.__ks_sttc_vcurry_0.apply(null, args);
	};
	__ks_Function._im_toSource = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		if(args.length === 0) {
			return __ks_Function.__ks_func_toSource_0.apply(that);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
	return {
		Function: Function,
		__ks_Function: __ks_Function
	};
};