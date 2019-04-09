module.exports = function() {
	function foo(x) {
		if(arguments.length < 1) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		for(let key in x.foo) {
			let value = x.foo[key];
			console.log(key, value);
		}
		for(let key in x.bar) {
			let value = x.bar[key];
			console.log(key, value);
		}
	}
};