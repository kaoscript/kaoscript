var {Dictionary, Type} = require("@kaoscript/runtime");
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
		const tokens = [];
		return (() => {
			const d = new Dictionary();
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
		let tokens = null, rules = null;
		for(let __ks_0 = 0, __ks_1 = lines.length, line; __ks_0 < __ks_1; ++__ks_0) {
			line = lines[__ks_0];
			let __ks_2;
			if(Type.isValue(__ks_2 = parse(line, rules)) ? (({tokens, rules} = __ks_2), true) : false) {
			}
		}
	}
};