module.exports = function() {
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
}