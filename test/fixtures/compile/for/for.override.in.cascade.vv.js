const {Helper, Operator, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(values) {
		const x = -1;
		for(let i = 0, __ks_0 = values.length, value; i < __ks_0; ++i) {
			value = values[i];
			const x = i;
			for(let i = 0, __ks_1 = Helper.length(value.values), __ks_value_1; i < __ks_1; ++i) {
				__ks_value_1 = value.values[i];
				const x = i;
				for(let i = 0, __ks_2 = Helper.length(__ks_value_1.values), __ks_value_2; i < __ks_2; ++i) {
					__ks_value_2 = __ks_value_1.values[i];
					const x = i;
					for(let i = 0, __ks_3 = Helper.length(__ks_value_2.values), __ks_value_3; i < __ks_3; ++i) {
						__ks_value_3 = __ks_value_2.values[i];
						const x = i;
					}
				}
			}
		}
		for(let i = 0, __ks_0 = values.length, value; i < __ks_0; ++i) {
			value = values[i];
			const x = Operator.multiplication(i, value.max);
		}
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isArray;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};