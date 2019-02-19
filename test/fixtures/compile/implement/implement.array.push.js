module.exports = function() {
	var __ks_Array = {};
	__ks_Array.__ks_func_contains_0 = function() {
		if(arguments.length < 1) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
		}
		let __ks_i = -1;
		let item = arguments[++__ks_i];
		if(item === void 0 || item === null) {
			throw new TypeError("'item' is not nullable");
		}
		let __ks__;
		let from = arguments.length > 1 && (__ks__ = arguments[++__ks_i]) !== void 0 && __ks__ !== null ? __ks__ : 0;
		return this.indexOf(item, from) !== -1;
	};
	__ks_Array.__ks_func_pushUniq_0 = function(...args) {
		if(args.length === 1) {
			if(!__ks_Array._im_contains(this, args[0])) {
				this.push(args[0]);
			}
		}
		else {
			for(let __ks_0 = 0, __ks_1 = args.length, item; __ks_0 < __ks_1; ++__ks_0) {
				item = args[__ks_0];
				if(!__ks_Array._im_contains(this, item)) {
					this.push(item);
				}
			}
		}
		return this;
	};
	__ks_Array._im_contains = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		if(args.length >= 1 && args.length <= 2) {
			return __ks_Array.__ks_func_contains_0.apply(that, args);
		}
		throw new SyntaxError("wrong number of arguments");
	};
	__ks_Array._im_pushUniq = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		return __ks_Array.__ks_func_pushUniq_0.apply(that, args);
	};
};