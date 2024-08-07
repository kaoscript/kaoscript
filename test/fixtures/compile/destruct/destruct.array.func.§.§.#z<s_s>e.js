const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Foobar = Helper.alias(value => Type.isDexArray(value, 1, 2, 0, 0, [Type.isString, Type.isString]));
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function([x, y]) {
		console.log(x + "." + y);
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isDexArray(value, 1, 2, 0, 0, [Type.isString, Type.isString]);
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};