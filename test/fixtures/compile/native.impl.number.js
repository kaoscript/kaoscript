var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	var __ks_Number = {};
	Helper.newInstanceMethod({
		class: Number,
		name: "mod",
		sealed: __ks_Number,
		function: function(max) {
			if(arguments.length < 1) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(max === void 0 || max === null) {
				throw new TypeError("'max' is not nullable");
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