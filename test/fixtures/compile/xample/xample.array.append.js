require("kaoscript/register");
module.exports = function() {
	var {Array, __ks_Array} = require("../_/_array.ks")();
	__ks_Array.__ks_func_appendAny_0 = function(...args) {
		console.log(__ks_Array._im_last(args));
		for(let i = 0, __ks_0 = args.length; i < __ks_0; ++i) {
			console.log(args[i].last());
			this.push.apply(this, [].concat(args[i]));
		}
		return this;
	};
	__ks_Array.__ks_func_appendArray_0 = function(...args) {
		console.log(__ks_Array._im_last(args));
		for(let i = 0, __ks_0 = args.length; i < __ks_0; ++i) {
			console.log(__ks_Array._im_last(args[i]));
			this.push(...args[i]);
		}
		return this;
	};
	__ks_Array._im_appendAny = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		return __ks_Array.__ks_func_appendAny_0.apply(that, args);
	};
	__ks_Array._im_appendArray = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		return __ks_Array.__ks_func_appendArray_0.apply(that, args);
	};
};