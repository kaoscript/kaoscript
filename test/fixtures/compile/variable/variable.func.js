const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foo() {
		return foo.__ks_rt(this, arguments);
	};
	foo.__ks_0 = function(bar = null) {
		let qux;
		if(Type.isValue(bar) ? (qux = bar, true) : false) {
			console.log(qux);
		}
	};
	foo.__ks_rt = function(that, args) {
		if(args.length <= 1) {
			return foo.__ks_0.call(that, args[0]);
		}
		throw Helper.badArgs();
	};
};