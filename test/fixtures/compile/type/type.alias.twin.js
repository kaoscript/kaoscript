const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const float = Helper.alias(Type.isNumber);
	const int = Helper.alias(Type.isNumber);
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(x, y) {
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isNumber;
		if(args.length === 2) {
			if(t0(args[0]) && t0(args[1])) {
				return foobar.__ks_0.call(that, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	};
	foobar.__ks_0(1, 2);
	let x = 1;
	let y = 1;
	foobar.__ks_0(x, y);
};