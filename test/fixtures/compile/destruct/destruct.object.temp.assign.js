const {Dictionary, Helper, Type} = require("@kaoscript/runtime");
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
			const d = new Dictionary();
			d.tokens = tokens;
			d.rules = rules;
			return d;
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
		let tokens = null, rules = null;
		for(let __ks_0 = 0, __ks_1 = lines.length, line; __ks_0 < __ks_1; ++__ks_0) {
			line = lines[__ks_0];
			({tokens, rules} = parse(line, rules));
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