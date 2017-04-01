module.exports = function() {
	var __ks_String = {};
	__ks_String.__ks_func_lowerFirst_0 = function() {
		return this.charAt(0).toLowerCase() + this.substring(1);
	};
	__ks_String._im_lowerFirst = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		if(args.length === 0) {
			return __ks_String.__ks_func_lowerFirst_0.apply(that);
		}
		throw new SyntaxError("wrong number of arguments");
	};
	let foo = "HELLO!";
	console.log(foo);
	console.log(__ks_String._im_lowerFirst(foo));
}