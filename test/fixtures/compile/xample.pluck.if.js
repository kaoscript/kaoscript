var {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Array = {};
	Helper.newInstanceMethod({
		class: Array,
		name: "pluck",
		sealed: __ks_Array,
		function: function(name) {
			if(name === undefined || name === null) {
				throw new Error("Missing parameter 'name'");
			}
			let result = [];
			let value;
			for(let __ks_0 = 0, __ks_1 = this.length, item; __ks_0 < __ks_1; ++__ks_0) {
				item = this[__ks_0];
				if(Type.isValue(item) && Type.isValue(item[name]) ? (value = item[name], true) : false) {
					if(Type.isFunction(value)) {
						let __ks_2;
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