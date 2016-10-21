var {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Array = {};
	Helper.newInstanceMethod({
		class: Array,
		name: "pluck",
		final: __ks_Array,
		function: function(name) {
			if(name === undefined || name === null) {
				throw new Error("Missing parameter 'name'");
			}
			let result = [];
			let value;
			for(let __ks_0 = 0, __ks_1 = this.length, item; __ks_0 < __ks_1; ++__ks_0) {
				item = this[__ks_0];
				let __ks_2;
				if((Type.isValue(item) ? Type.isValue(__ks_2 = item[name]) : false) ? (value = __ks_2, true) : false) {
					if(Type.isFunction(value)) {
						if(Type.isValue(__ks_2 = value.call(item)) ? (value = __ks_2, true) : false) {
							result.push(value);
						}
					}
					else {
						result.push(value);
					}
				}
			}
			return result;
		},
		signature: {
			access: 3,
			min: 1,
			max: 1,
			parameters: [
				{
					type: "Any",
					min: 1,
					max: 1
				}
			]
		}
	});
}