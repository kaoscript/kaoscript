module.exports = function() {
	function foo() {
		if(arguments.length < 3) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 3)");
		}
		let __ks_i = -1;
		let args = Array.prototype.slice.call(arguments, __ks_i + 1, Math.min(arguments.length, __ks_i + 4));
	}
};