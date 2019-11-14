var Dictionary = require("@kaoscript/runtime").Dictionary;
module.exports = function() {
	function parse(line, rules) {
		if(arguments.length < 2) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
		}
		if(line === void 0 || line === null) {
			throw new TypeError("'line' is not nullable");
		}
		if(rules === void 0) {
			rules = null;
		}
		var tokens = [];
		return (function() {
			var d = new Dictionary();
			d.tokens = tokens;
			d.rules = rules;
			return d;
		})();
	}
	function foobar(lines) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(lines === void 0 || lines === null) {
			throw new TypeError("'lines' is not nullable");
		}
		var tokens, rules;
		for(var __ks_0 = 0, __ks_1 = lines.length, line; __ks_0 < __ks_1; ++__ks_0) {
			line = lines[__ks_0];
			var __ks_2;
			tokens = (__ks_2 = parse(line, rules)).tokens, rules = __ks_2.rules;
		}
	}
};