var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	var __ks_Number = {};
	Helper.newInstanceMethod({
		class: Number,
		name: "mod",
		final: __ks_Number,
		function: function(max) {
			if(max === undefined || max === null) {
				throw new Error("Missing parameter 'max'");
			}
			if(isNaN(this)) {
				return 0;
			}
			else {
				let n = this % max;
				if(n < 0) {
					return n + max;
				}
				else {
					return n;
				}
			}
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
	console.log(__ks_Number._im_mod(42, 3));
}