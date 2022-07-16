const {Dictionary, Helper} = require("@kaoscript/runtime");
module.exports = function() {
	function foo() {
		return foo.__ks_rt(this, arguments);
	};
	foo.__ks_0 = function() {
		return (() => {
			const d = new Dictionary();
			d.x = 1;
			d.y = 2;
			return d;
		})();
	};
	foo.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return foo.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
	const {x, y} = foo.__ks_0();
	console.log(x, y);
};