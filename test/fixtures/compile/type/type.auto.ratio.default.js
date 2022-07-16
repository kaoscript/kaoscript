require("kaoscript/register");
const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Number = require("../_/._number.ks.j5k8r9.ksb")().__ks_Number;
	function foo() {
		return foo.__ks_rt(this, arguments);
	};
	foo.__ks_0 = function() {
		return 0.32;
	};
	foo.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return foo.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
	let l1 = foo.__ks_0() + 0.05;
	let l2 = foo.__ks_0() + 0.05;
	let ratio = l1 / l2;
	console.log(__ks_Number.__ks_func_round_0.call(ratio, 2));
};