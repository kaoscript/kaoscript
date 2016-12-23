var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	var __ks_Boolean = {};
	var __ks_String = {};
	Helper.newInstanceMethod({
		class: Boolean,
		name: "toBoolean",
		sealed: __ks_Boolean,
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
		name: "toBoolean",
		sealed: __ks_String,
		function: function() {
			return /^(?:true|1|on|yes)$/i.test(this);
		},
		signature: {
			access: 3,
			min: 0,
			max: 0,
			parameters: []
		}
	});
	console.log(__ks_Boolean._im_toBoolean(true));
	console.log(__ks_String._im_toBoolean("true"));
}