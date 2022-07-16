const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(x, y) {
		let z = null;
		if(x === 0) {
			z = 1;
		}
		else if(y === 0) {
			return 0;
		}
		else if((x === 1) && (y === 1)) {
			z = 2;
		}
		else {
			z = 0;
		}
		return z;
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 2) {
			if(t0(args[0]) && t0(args[1])) {
				return foobar.__ks_0.call(that, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	};
};