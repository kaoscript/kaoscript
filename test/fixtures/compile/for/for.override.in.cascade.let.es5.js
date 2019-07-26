var Type = require("@kaoscript/runtime").Type;
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
		var x = -1;
		for(var i = 0, __ks_0 = values.length, value; i < __ks_0; ++i) {
			value = values[i];
			var __ks_x_1 = i;
			for(var __ks_i_1 = 0, __ks_1 = value.values.length, __ks_value_1; __ks_i_1 < __ks_1; ++__ks_i_1) {
				__ks_value_1 = value.values[__ks_i_1];
				var __ks_x_2 = __ks_i_1;
				for(var __ks_i_2 = 0, __ks_2 = __ks_value_1.values.length, __ks_value_2; __ks_i_2 < __ks_2; ++__ks_i_2) {
					__ks_value_2 = __ks_value_1.values[__ks_i_2];
					var __ks_x_3 = __ks_i_2;
					for(var __ks_i_3 = 0, __ks_3 = __ks_value_2.values.length, __ks_value_3; __ks_i_3 < __ks_3; ++__ks_i_3) {
						__ks_value_3 = __ks_value_2.values[__ks_i_3];
						var __ks_x_4 = __ks_i_3;
					}
				}
			}
		}
		for(var i = 0, __ks_0 = values.length, value; i < __ks_0; ++i) {
			value = values[i];
			var __ks_x_1 = i * value.max;
		}
	}
};