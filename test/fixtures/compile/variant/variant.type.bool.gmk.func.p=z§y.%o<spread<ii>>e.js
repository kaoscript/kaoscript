const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ksType = {
		isEvent: (value, mapper, filter) => Type.isDexObject(value, 1, 0, {ok: variant => {
			if(!Type.isBoolean(variant)) {
				return false;
			}
			if(filter && !filter(variant)) {
				return false;
			}
			if(variant) {
				return Type.isDexObject(value, 0, 0, {value: mapper[0], line: Type.isNumber, column: Type.isNumber});
			}
			else {
				return Type.isDexObject(value, 0, 0, {expecting: value => Type.isString(value) || Type.isNull(value)});
			}
		}})
	};
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(value) {
		return (() => {
			const o = new OBJ();
			o.line = value.line;
			o.column = value.column;
			return o;
		})();
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => __ksType.isEvent(value, [Type.any], value => value);
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};