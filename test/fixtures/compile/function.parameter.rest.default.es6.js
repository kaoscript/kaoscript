var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	function foo(...items) {
		console.log(items);
	}
	function bar(x, ...items) {
		if(x === undefined || x === null) {
			throw new Error("Missing parameter 'x'");
		}
		console.log(x, items);
	}
	function baz(x) {
		if(arguments.length < 2) {
			throw new Error("Wrong number of arguments");
		}
		if(x === undefined || x === null) {
			throw new Error("Missing parameter 'x'");
		}
		let __ks_i;
		let items = arguments.length > 2 ? Array.prototype.slice.call(arguments, 1, __ks_i = arguments.length - 1) : (__ks_i = 1, []);
		var z = arguments[__ks_i];
		console.log(x, items, z);
	}
	function qux(x, ...items) {
		if(x === undefined || x === null) {
			throw new Error("Missing parameter 'x'");
		}
		var z = 1;
		console.log(x, items, z);
	}
	function quux() {
		let __ks_i = -1;
		if(arguments.length > 0) {
			var x = arguments[++__ks_i];
		}
		else {
			var x = 1;
		}
		let items = arguments.length > ++__ks_i ? Array.prototype.slice.call(arguments, __ks_i, __ks_i = arguments.length) : [];
		__ks_i += items.length;
		var z = 1;
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
			throw new Error("Wrong number of arguments");
		}
		let __ks_i;
		let items = arguments.length > 1 ? Array.prototype.slice.call(arguments, 0, __ks_i = arguments.length - 1) : (__ks_i = 0, []);
		var z = arguments[__ks_i];
		console.log(items, z);
	}
	function garply(...items) {
		var z = 1;
		console.log(items, z);
	}
	function waldo() {
		if(arguments.length < 3) {
			throw new Error("Wrong number of arguments");
		}
		let __ks_i;
		let items = arguments.length > 3 ? Array.prototype.slice.call(arguments, 0, __ks_i = arguments.length - 3) : (__ks_i = 0, []);
		var x = arguments[__ks_i];
		var y = arguments[++__ks_i];
		var z = arguments[++__ks_i];
		console.log(items, x, y, z);
	}
	function fred() {
		if(arguments.length < 2) {
			throw new Error("Wrong number of arguments");
		}
		let __ks_i;
		let items = arguments.length > 2 ? Array.prototype.slice.call(arguments, 0, __ks_i = arguments.length - 2) : (__ks_i = 0, []);
		var x = arguments[__ks_i];
		var y = 1;
		var z = arguments[++__ks_i];
		console.log(items, x, y, z);
	}
}