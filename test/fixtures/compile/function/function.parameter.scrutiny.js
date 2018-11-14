var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foo(x) {
		if(arguments.length < 1) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		console.log(x);
	}
	function bar(x) {
		if(arguments.length < 1) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(x === void 0) {
			x = null;
		}
		console.log(x);
	}
	function baz(x = null) {
		console.log(x);
	}
	function qux(x) {
		if(x === void 0 || x === null) {
			x = "foobar";
		}
		console.log(x);
	}
	function quux(x) {
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
	}
	function corge(x) {
		if(arguments.length < 1) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(x === void 0) {
			x = null;
		}
		else if(x !== null && !Type.isString(x)) {
			throw new TypeError("'x' is not of type 'String'");
		}
		console.log(x);
	}
	function grault(x = null) {
		if(x !== null && !Type.isString(x)) {
			throw new TypeError("'x' is not of type 'String'");
		}
		console.log(x);
	}
	function garply(x) {
		if(x === void 0 || x === null) {
			x = "foobar";
		}
		else if(!Type.isString(x)) {
			throw new TypeError("'x' is not of type 'String'");
		}
		console.log(x);
	}
	function waldo(x = null) {
		if(x !== null && !Type.isString(x)) {
			throw new TypeError("'x' is not of type 'String'");
		}
		console.log(x);
	}
	function fred(x = "foobar") {
		if(x !== null && !Type.isString(x)) {
			throw new TypeError("'x' is not of type 'String'");
		}
		console.log(x);
	}
};