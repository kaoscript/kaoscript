require("kaoscript/register");
module.exports = function() {
	var __ks_Number = require("../_/_number.ks")().__ks_Number;
	function foo() {
		return 0.32;
	}
	let l1 = foo() + 0.05;
	let l2 = foo() + 0.05;
	let ratio = l1 / l2;
	console.log(__ks_Number._im_round(ratio, 2));
};