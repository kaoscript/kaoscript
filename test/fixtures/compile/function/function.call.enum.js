const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Foobar = Helper.enum(Number, 0, "X", 0, "Y", 1, "Z", 2);
	function toString() {
		return toString.__ks_rt(this, arguments);
	};
	toString.__ks_0 = function(foo) {
		return "xyz";
	};
	toString.__ks_rt = function(that, args) {
		const t0 = value => Type.isEnumInstance(value, Foobar);
		if(args.length === 1) {
			if(t0(args[0])) {
				return toString.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	console.log(toString.__ks_0(Foobar.X));
};