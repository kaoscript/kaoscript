var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	var __ks_String = {};
	Helper.newInstanceMethod({
		class: String,
		name: "capitalize",
		sealed: __ks_String,
		function: function() {
			return this;
		},
		signature: {
			access: 3,
			min: 0,
			max: 0,
			parameters: []
		}
	});
	Helper.newInstanceMethod({
		class: String,
		name: "capitalizeWords",
		sealed: __ks_String,
		function: function() {
			return Helper.mapArray(this.split(" "), function(item) {
				return __ks_String._im_capitalize(item);
			}).join(" ");
		},
		signature: {
			access: 3,
			min: 0,
			max: 0,
			parameters: []
		}
	});
}