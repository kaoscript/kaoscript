module.exports = function() {
	function foobar(__ks_0) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(__ks_0 === void 0 || __ks_0 === null) {
			throw new TypeError("Destructuring value is not nullable");
		}
		var x = __ks_0[0], y = __ks_0[1];
		console.log(x + "." + y);
	}
};