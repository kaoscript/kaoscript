const {Helper, Operator, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(parameter) {
		let __ks_0, __ks_1, __ks_2, __ks_3;
		[__ks_0, __ks_1, __ks_2, __ks_3] = Helper.assertLoop(0, "", 1, "parameter.min()", parameter.min(), "", 1);
		for(let __ks_4 = __ks_0, i; __ks_4 <= __ks_1; __ks_4 += __ks_2) {
			i = __ks_3(__ks_4);
		}
		[__ks_0, __ks_1, __ks_2, __ks_3] = Helper.assertLoop(0, "parameter.min() + 1", Operator.add(parameter.min(), 1), "parameter.max()", parameter.max(), "", 1);
		for(let __ks_4 = __ks_0, i; __ks_4 <= __ks_1; __ks_4 += __ks_2) {
			i = __ks_3(__ks_4);
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