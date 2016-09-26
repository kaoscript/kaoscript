var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	var __ks_String = {};
	Helper.newInstanceMethod({
		class: String,
		name: "toInt",
		final: __ks_String,
		function: function(base) {
			if(base === undefined || base === null) {
				base = 10;
			}
			return parseInt(this, base);
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
	let d = 4;
	let u = 2;
	console.log(__ks_String._im_toInt(d + u));
}