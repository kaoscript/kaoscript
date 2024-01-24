const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(values) {
		return (() => {
			const a = [];
			for(let __ks_0 in values) {
				const vals = values[__ks_0];
				a.push(...vals);
			}
			return a;
		})();
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isDexObject(value, 1, value => Type.isArray(value, Type.isNumber));
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};