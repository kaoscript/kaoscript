var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	function foo(...items) {
		console.log(items);
	}
	function bar(x, ...items) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		console.log(x, items);
	}
	function baz(x) {
		if(arguments.length < 2) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		let __ks_i = 0;
		let items = arguments.length > ++__ks_i + 1 ? Array.prototype.slice.call(arguments, __ks_i, __ks_i = arguments.length - 1) : [];
		let z = arguments[__ks_i];
		if(z === void 0 || z === null) {
			throw new TypeError("'z' is not nullable");
		}
		console.log(x, items, z);
	}
	function qux(x, ...items) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		let z = 1;
		console.log(x, items, z);
	}
	function quux(x, ...items) {
		if(x === void 0 || x === null) {
			x = 1;
		}
		let z = 1;
		console.log(x, items, z);
	}
	function corge(...items) {
		if(items.length === 0) {
			items = Helper.newArrayRange(1, 5, 1, true, true);
		}
		console.log(items);
	}
	function grault() {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		let __ks_i = -1;
		let items = arguments.length > ++__ks_i + 1 ? Array.prototype.slice.call(arguments, __ks_i, __ks_i = arguments.length - 1) : [];
		let z = arguments[__ks_i];
		if(z === void 0 || z === null) {
			throw new TypeError("'z' is not nullable");
		}
		console.log(items, z);
	}
	function garply(...items) {
		let z = 1;
		console.log(items, z);
	}
	function waldo() {
		if(arguments.length < 3) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 3)");
		}
		let __ks_i = -1;
		let items = arguments.length > ++__ks_i + 3 ? Array.prototype.slice.call(arguments, __ks_i, __ks_i = arguments.length - 3) : [];
		let x = arguments[__ks_i];
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		let y = arguments[++__ks_i];
		if(y === void 0 || y === null) {
			throw new TypeError("'y' is not nullable");
		}
		let z = arguments[++__ks_i];
		if(z === void 0 || z === null) {
			throw new TypeError("'z' is not nullable");
		}
		console.log(items, x, y, z);
	}
	function fred() {
		if(arguments.length < 2) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
		}
		let __ks_i = -1;
		let items = arguments.length > ++__ks_i + 2 ? Array.prototype.slice.call(arguments, __ks_i, __ks_i = arguments.length - 2) : [];
		let x = arguments[__ks_i];
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		let y = 1;
		let z = arguments[++__ks_i];
		if(z === void 0 || z === null) {
			throw new TypeError("'z' is not nullable");
		}
		console.log(items, x, y, z);
	}
};