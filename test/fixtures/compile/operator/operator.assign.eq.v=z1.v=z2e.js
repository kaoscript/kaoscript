const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Range = Helper.alias(value => Type.isDexObject(value, 1, 0, {start: Type.isNumber, end: Type.isNumber}));
	const Event = Helper.alias(value => Type.isDexObject(value, 1, 0, {value: Type.isString, start: Type.isNumber, end: Type.isNumber}));
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(test, e) {
		let r = null;
		if(test) {
			r = e;
			return r;
		}
		return e;
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isBoolean;
		const t1 = Event.is;
		if(args.length === 2) {
			if(t0(args[0]) && t1(args[1])) {
				return foobar.__ks_0.call(that, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	};
};