var {Operator, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar(values) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(values === void 0 || values === null) {
			throw new TypeError("'values' is not nullable");
		}
		else if(!Type.isArray(values)) {
			throw new TypeError("'values' is not of type 'Array'");
		}
		let x = -1;
		for(let i = 0, __ks_0 = values.length, value; i < __ks_0; ++i) {
			value = values[i];
			let x = i;
			for(let i = 0, __ks_1 = value.values.length, __ks_value_1; i < __ks_1; ++i) {
				__ks_value_1 = value.values[i];
				let x = i;
				for(let i = 0, __ks_2 = __ks_value_1.values.length, __ks_value_2; i < __ks_2; ++i) {
					__ks_value_2 = __ks_value_1.values[i];
					let x = i;
					for(let i = 0, __ks_3 = __ks_value_2.values.length, __ks_value_3; i < __ks_3; ++i) {
						__ks_value_3 = __ks_value_2.values[i];
						let x = i;
					}
				}
			}
		}
		for(let i = 0, __ks_0 = values.length, value; i < __ks_0; ++i) {
			value = values[i];
			let x = Operator.multiplication(i, value.max);
		}
	}
};