const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function parse() {
		return parse.__ks_rt(this, arguments);
	};
	parse.__ks_0 = function(line, rules) {
		if(rules === void 0) {
			rules = null;
		}
		const tokens = [];
		return (() => {
			const o = new OBJ();
			o.tokens = tokens;
			o.rules = rules;
			return o;
		})();
	};
	parse.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 2) {
			if(t0(args[0])) {
				return parse.__ks_0.call(that, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	};
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(lines) {
		let tokens, rules;
		for(let __ks_1 = 0, __ks_0 = lines.length, line; __ks_1 < __ks_0; ++__ks_1) {
			line = lines[__ks_1];
			({tokens, rules} = Helper.assert(parse(line, rules), "\"{tokens: Any, rules: Any}\"", 0, value => Type.isDexObject(value, 1, 0, {tokens: Type.isValue, rules: Type.isValue})));
		}
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};