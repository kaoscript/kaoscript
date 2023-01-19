const {Helper, OBJ} = require("@kaoscript/runtime");
module.exports = function() {
	function foo() {
		return foo.__ks_rt(this, arguments);
	};
	foo.__ks_0 = function() {
		return (() => {
			const o = new OBJ();
			o.bar = "hello";
			o.baz = 3;
			return o;
		})();
	};
	foo.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return foo.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
	let bar = 0;
	let baz;
	({bar, baz} = foo.__ks_0());
	console.log(bar);
	console.log(baz);
};