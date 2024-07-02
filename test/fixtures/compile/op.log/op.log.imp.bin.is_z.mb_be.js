const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Foobar = Helper.alias(value => Type.isDexObject(value, 1, 0, {flag: Type.isBoolean, name: Type.isString}));
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(value) {
		if(!Foobar.is(value) || value.flag) {
			console.log(Helper.toString(value.name));
		}
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};