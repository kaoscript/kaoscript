const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Range = Helper.alias(value => Type.isDexObject(value, 1, 0, {start: Type.isNumber, end: Type.isNumber}));
	const Event = Helper.alias((value, mapper, filter) => Type.isDexObject(value, 1, 0, {ok: variant => {
		if(!Type.isBoolean(variant)) {
			return false;
		}
		if(filter && !filter(variant)) {
			return false;
		}
		if(variant) {
			return Event.isTrue(value, mapper);
		}
		else {
			return Event.isFalse(value);
		}
	}}));
	Event.isFalse = value => Type.isDexObject(value, 0, 0, {start: value => Type.isNumber(value) || Type.isNull(value), end: value => Type.isNumber(value) || Type.isNull(value)});
	Event.isTrue = (value, mapper) => Type.isDexObject(value, 0, 0, {value: mapper[0], start: Type.isNumber, end: Type.isNumber});
	const NO = (() => {
		const o = new OBJ();
		o.ok = false;
		return o;
	})();
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(value) {
		let x = null;
		let y = NO;
		x = y = value;
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Event.is(value, [Type.any], value => value);
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};