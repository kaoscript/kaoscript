module.exports = function() {
	var __ks_Function = {};
	__ks_Function.__ks_func_foo_0 = function() {
		return "foo" + this();
	};
	__ks_Function._im_foo = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		if(args.length === 0) {
			return __ks_Function.__ks_func_foo_0.apply(that);
		}
		throw new SyntaxError("wrong number of arguments");
	};
	function bar() {
		return "bar";
	}
	console.log(__ks_Function._im_foo(bar));
}