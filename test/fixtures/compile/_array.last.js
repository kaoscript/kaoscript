var Helper = require("@kaoscript/runtime").Helper;
module.exports = function(Array, __ks_Array) {
	Helper.newInstanceMethod({
		class: Array,
		name: "last",
		final: __ks_Array,
		function: function(index) {
			if(index === undefined || index === null) {
				index = 1;
			}
			return this.length ? this[this.length - index] : null;
		},
		signature: {
			access: 3,
			min: 0,
			max: 1,
			parameters: [
				{
					type: "Any",
					min: 0,
					max: 1
				}
			]
		}
	});
	return {
		Array: Array,
		__ks_Array: __ks_Array
	};
}