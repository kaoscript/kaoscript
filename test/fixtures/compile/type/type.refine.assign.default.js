var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foo() {
		return "";
	}
	function bar() {
		return "";
	}
	function corge(x) {
		if(arguments.length < 1) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
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
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		console.log("" + x);
		x = foo();
		console.log("" + x);
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
	console.log("" + y);
	y = bar();
	console.log(y);
	return {
		corge: corge,
		grault: grault,
		x: x,
		y: y
	};
};