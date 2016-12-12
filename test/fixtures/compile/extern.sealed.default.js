var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	var __ks_Number = {};
	Helper.newInstanceMethod({
		class: Number,
		name: "zeroPad",
		sealed: __ks_Number,
		function: function() {
			return "00" + this.toString();
		},
		signature: {
			access: 3,
			min: 0,
			max: 0,
			parameters: []
		}
	});
	var __ks_Math = {};
	__ks_Number._im_zeroPad(Math.pow(3, 2));
	__ks_Number._im_zeroPad(Math.PI);
}