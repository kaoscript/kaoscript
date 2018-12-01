module.exports = function() {
	var __ks_SyntaxError = {};
	__ks_SyntaxError.__ks_func_foo_0 = function() {
		return "bar";
	};
	__ks_SyntaxError._im_foo = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		if(args.length === 0) {
			return __ks_SyntaxError.__ks_func_foo_0.apply(that);
		}
		throw new SyntaxError("wrong number of arguments");
	};
	function foo() {
	}
	return {
		foo: foo,
		SyntaxError: SyntaxError,
		__ks_SyntaxError: __ks_SyntaxError
	};
};