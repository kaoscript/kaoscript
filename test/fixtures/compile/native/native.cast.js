module.exports = function() {
	var __ks_String = {};
	__ks_String.__ks_func_lower_0 = function() {
		return this.toLowerCase();
	};
	__ks_String._im_lower = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		if(args.length === 0) {
			return __ks_String.__ks_func_lower_0.apply(that);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
	let foo = "HELLO!";
	console.log(foo);
	console.log(__ks_String._im_lower(foo));
};