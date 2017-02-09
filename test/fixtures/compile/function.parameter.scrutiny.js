var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foo(x) {
		if(x === undefined || x === null) {
			throw new Error("Missing parameter 'x'");
		}
		console.log(x);
	}
	function bar(x) {
		if(x === undefined) {
			throw new Error("Missing parameter 'x'");
		}
		console.log(x);
	}
	function baz(x = null) {
		console.log(x);
	}
	function qux(x) {
		if(x === undefined || x === null) {
			x = "foobar";
		}
		console.log(x);
	}
	function quux(x) {
		if(x === undefined || x === null) {
			throw new Error("Missing parameter 'x'");
		}
		else if(!Type.isString(x)) {
			throw new Error("Invalid type for parameter 'x'");
		}
		console.log(x);
	}
	function corge(x) {
		if(x === undefined) {
			throw new Error("Missing parameter 'x'");
		}
		else if(x !== null && !Type.isString(x)) {
			throw new Error("Invalid type for parameter 'x'");
		}
		console.log(x);
	}
	function grault(x = null) {
		if(x !== null && !Type.isString(x)) {
			throw new Error("Invalid type for parameter 'x'");
		}
		console.log(x);
	}
	function garply(x) {
		if(x === undefined || x === null) {
			x = "foobar";
		}
		else if(!Type.isString(x)) {
			throw new Error("Invalid type for parameter 'x'");
		}
		console.log(x);
	}
	function waldo(x = null) {
		if(x !== null && !Type.isString(x)) {
			throw new Error("Invalid type for parameter 'x'");
		}
		console.log(x);
	}
	function fred(x = "foobar") {
		if(x !== null && !Type.isString(x)) {
			throw new Error("Invalid type for parameter 'x'");
		}
		console.log(x);
	}
}