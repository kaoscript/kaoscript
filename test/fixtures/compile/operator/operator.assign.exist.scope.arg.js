const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foo() {
		return foo.__ks_rt(this, arguments);
	};
	foo.__ks_0 = function() {
		return this.message;
	};
	foo.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return foo.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
	let bar, __ks_0;
	Type.isValue(__ks_0 = foo.__ks_0.call(context)) ? bar = __ks_0 : null;
	console.log(foo, bar);
};