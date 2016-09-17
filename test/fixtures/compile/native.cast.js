var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	var __ks_String = {};
	Helper.newInstanceMethod({
		class: String,
		name: "lower",
		final: __ks_String,
		method: "toLowerCase",
		signature: {
			access: 3,
			min: 0,
			max: 0,
			parameters: [
			]
		}
	});
	let foo = "HELLO!";
	console.log(foo);
	console.log(__ks_String._im_lower(foo));
}