require("kaoscript/register");
const {Dictionary, Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Number = require("../_/._number.ks.j5k8r9.ksb")().__ks_Number;
	let $caster = (() => {
		const d = new Dictionary();
		d.hex = Helper.function(function(n) {
			return __ks_Number.__ks_func_round_0.call(__ks_Number.__ks_func_limit_0.call(Float.parse(n), 0, 255));
		}, (fn, ...args) => {
			const t0 = value => Type.isNumber(value) || Type.isString(value);
			if(args.length === 1) {
				if(t0(args[0])) {
					return fn.call(null, args[0]);
				}
			}
			throw Helper.badArgs();
		});
		return d;
	})();
	console.log($caster.hex.__ks_0(128));
};