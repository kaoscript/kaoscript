var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	var __ks_Function = {};
	Helper.newInstanceMethod({
		class: Function,
		name: "foo",
		sealed: __ks_Function,
		function: function() {
			return "foo" + this();
		},
		signature: {
			access: 3,
			min: 0,
			max: 0,
			parameters: []
		}
	});
	console.log(__ks_Function._im_foo(function() {
		return "bar";
	}));
}