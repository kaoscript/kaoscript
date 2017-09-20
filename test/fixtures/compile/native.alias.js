var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	var __ks_String = {};
	Helper.newInstanceMethod({
		class: String,
		name: "lower",
		sealed: __ks_String,
		method: "toLowerCase",
		signature: {
			access: 3,
			min: 0,
			max: 0,
			parameters: []
		}
	});
	let foo = "HELLO!";
	console.log(foo);
	console.log(foo.toLowerCase());
	console.log(__ks_String._im_lower(foo));
	let bar = "HELLO!";
	console.log(bar);
	console.log(bar.toLowerCase());
	console.log(bar.lower());
};