const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(i, b) {
		let x = i;
		do {
			x = null;
		}
		while(!(b))
		if(x === null) {
		}
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isNumber;
		const t1 = Type.isBoolean;
		if(args.length === 2) {
			if(t0(args[0]) && t1(args[1])) {
				return foobar.__ks_0.call(that, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	};
};