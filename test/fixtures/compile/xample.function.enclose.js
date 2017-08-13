module.exports = function() {
	var __ks_Function = {};
	__ks_Function.__ks_func_enclose_0 = function(enclosure) {
		if(arguments.length < 1) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(enclosure === void 0 || enclosure === null) {
			throw new TypeError("'enclosure' is not nullable");
		}
		let f = this;
		return function(...args) {
			return enclosure(f, ...args);
		};
	};
	__ks_Function._im_enclose = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		if(args.length === 1) {
			return __ks_Function.__ks_func_enclose_0.apply(that, args);
		}
		throw new SyntaxError("wrong number of arguments");
	};
}