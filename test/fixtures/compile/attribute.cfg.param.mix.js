module.exports = function(Array, __ks_Array, Class, Function, __ks_Function, Object, __ks_Object, Type) {
	function foo(x, y) {
		if(arguments.length < 2) {
			throw new Error("Wrong number of arguments");
		}
		if(x === undefined || x === null) {
			throw new Error("Missing parameter 'x'");
		}
		if(y === undefined || y === null) {
			y = 1;
		}
		let __ks_i;
		let args = arguments.length > 3 ? Array.prototype.slice.call(arguments, 2, __ks_i = arguments.length - 1) : (__ks_i = 2, []);
		var z = arguments[__ks_i];
		console.log(x, y, args, z);
	}
	function bar(x, y = 1, ...args) {
		console.log(x, y, args);
	}
	function baz(x, y) {
		console.log(x, y);
	}
	function qux(x, y) {
		if(arguments.length < 2) {
			throw new Error("Wrong number of arguments");
		}
		if(x === undefined || x === null) {
			throw new Error("Missing parameter 'x'");
		}
		if(y === undefined || y === null) {
			y = 1;
		}
		let __ks_i;
		let args = arguments.length > 3 ? Array.prototype.slice.call(arguments, 2, __ks_i = arguments.length - 1) : (__ks_i = 2, []);
		var z = arguments[__ks_i];
		console.log(x, y, args, z);
	}
}