const {Dictionary, Helper} = require("@kaoscript/runtime");
module.exports = function() {
	function foo() {
		return foo.__ks_rt(this, arguments);
	};
	foo.__ks_0 = function() {
		return (() => {
			const d = new Dictionary();
			d.bar = "hello";
			d.baz = 3;
			return d;
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