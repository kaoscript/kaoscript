const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ksType = {
		isPosition: value => Type.isDexObject(value, 1, 0, {line: Type.isNumber, column: Type.isNumber}),
		isRange: value => Type.isDexObject(value, 1, 0, {start: __ksType.isPosition, end: __ksType.isPosition}),
		isEvent: (value, filter) => Type.isDexObject(value, 1, 0, {ok: variant => {
			if(!Type.isBoolean(variant)) {
				return false;
			}
			if(filter && !filter(variant)) {
				return false;
			}
			if(variant) {
				return Type.isDexObject(value, 0, 0, {value: Type.isValue, start: __ksType.isPosition, end: __ksType.isPosition});
			}
			else {
				return Type.isDexObject(value, 0, 0, {expecteds: value => Type.isArray(value, Type.isString) || Type.isNull(value)});
			}
		}})
	};
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(first) {
		if(first === void 0) {
			first = null;
		}
		const event = getEvent.__ks_0();
		if(!Type.isValue(first)) {
			first = event;
		}
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => __ksType.isRange(value) || Type.isNull(value);
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	function getEvent() {
		return getEvent.__ks_rt(this, arguments);
	};
	getEvent.__ks_0 = function() {
		return (() => {
			const o = new OBJ();
			o.ok = true;
			o.value = 0;
			o.start = (() => {
				const o = new OBJ();
				o.line = 1;
				o.column = 1;
				return o;
			})();
			o.end = (() => {
				const o = new OBJ();
				o.line = 1;
				o.column = 1;
				return o;
			})();
			return o;
		})();
	};
	getEvent.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return getEvent.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
};