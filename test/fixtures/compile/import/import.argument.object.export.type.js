var {Dictionary, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function corge() {
		return 42;
	}
	function grault(n) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(n === void 0 || n === null) {
			throw new TypeError("'n' is not nullable");
		}
		else if(!Type.isNumber(n)) {
			throw new TypeError("'n' is not of type 'Number'");
		}
		return n + 42;
	}
	function garply(s) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(s === void 0 || s === null) {
			throw new TypeError("'s' is not nullable");
		}
		else if(!Type.isString(s)) {
			throw new TypeError("'s' is not of type 'String'");
		}
		return s.toUpperCase();
	}
	function waldo() {
		return "miss White";
	}
	const foobar = (() => {
		const d = new Dictionary();
		d.corge = corge;
		d.grault = grault;
		d.garply = garply;
		d.waldo = waldo;
		return d;
	})();
	return {
		foobar: foobar
	};
};