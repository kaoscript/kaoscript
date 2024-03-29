const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foo() {
		return foo.__ks_rt(this, arguments);
	};
	foo.__ks_0 = function() {
		return [1, 2];
	};
	foo.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return foo.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
	let  __ks_0 = foo.__ks_0();
	Helper.assertDexArray(__ks_0, 1, 2, 0, 0, [Type.isValue, Type.isValue]);
	let [x, y] = __ks_0;
	console.log(x, y);
};