const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const x = 42;
	function foo() {
		return foo.__ks_rt(this, arguments);
	};
	foo.__ks_0 = function() {
		let x = null;
		let __ks_0;
		if(Type.isValue(__ks_0 = bar()) ? (x = __ks_0, true) : false) {
			console.log(x);
		}
	};
	foo.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return foo.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
};