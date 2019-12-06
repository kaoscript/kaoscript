module.exports = function() {
	var __ks_Number = {};
	__ks_Number.__ks_func_toString_0 = function() {
		return "" + this;
	};
	__ks_Number._im_toString = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		if(args.length === 0) {
			return __ks_Number.__ks_func_toString_0.apply(that);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
	var __ks_String = {};
	__ks_String.__ks_func_toString_0 = function() {
		return this;
	};
	__ks_String._im_toString = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		if(args.length === 0) {
			return __ks_String.__ks_func_toString_0.apply(that);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
	let x = null;
	if(true) {
		let x = null;
		x = "foobar";
		console.log(__ks_String._im_toString(x));
	}
	x = 42;
	console.log(__ks_Number._im_toString(x));
};