const {OBJ, Type} = require("@kaoscript/runtime");
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
				return Type.isDexObject(value, 0, 0, {value: mapper[0], line: value => Type.isNumber(value) || Type.isNull(value), column: value => Type.isNumber(value) || Type.isNull(value)});
			}
			else {
				return Type.isDexObject(value, 0, 0, {expecting: value => Type.isString(value) || Type.isNull(value)});
			}
		}})
	};
	const YES = (() => {
		const o = new OBJ();
		o.ok = true;
		return o;
	})();
};