var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	var __ks_Array = {};
	Helper.newInstanceMethod({
		class: Array,
		name: "last",
		sealed: __ks_Array,
		function: function(index) {
			if(index === void 0 || index === null) {
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
	console.log(__ks_Array._im_last([1, 2, 3]));
}