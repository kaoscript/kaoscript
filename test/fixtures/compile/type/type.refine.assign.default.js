var {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foo() {
		return "";
	}
	function bar() {
		return "";
	}
	function corge(x) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		else if(!Type.isString(x)) {
			throw new TypeError("'x' is not of type 'String'");
		}
		console.log(x);
		x = foo();
		console.log(x);
		x = bar();
		console.log(x);
	}
	function grault(x) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		console.log(Helper.toString(x));
		x = foo();
		console.log(Helper.toString(x));
		x = bar();
		console.log(x);
	}
	let x = "";
	console.log(x);
	x = foo();
	console.log(x);
	x = bar();
	console.log(x);
	let y = "";
	console.log(y);
	y = foo();
	console.log(Helper.toString(y));
	y = bar();
	console.log(y);
	return {
		corge: corge,
		grault: grault,
		x: x,
		y: y
	};
};