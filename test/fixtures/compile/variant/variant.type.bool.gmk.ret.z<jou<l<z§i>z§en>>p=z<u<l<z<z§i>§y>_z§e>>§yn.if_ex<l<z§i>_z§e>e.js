const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ksType = {
		isPosition: value => Type.isDexObject(value, 1, 0, {line: Type.isNumber, column: Type.isNumber}),
		isNodeData: (value, filter) => __ksType.isPosition(value) && Type.isDexObject(value, 1, 0, {kind: variant => {
			if(!Type.isEnumInstance(variant, NodeKind)) {
				return false;
			}
			if(filter && !filter(variant)) {
				return false;
			}
			if(variant === NodeKind.TypeReference) {
				return Type.isDexObject(value, 0, 0, {subtypes: value => Type.isArray(value, value => __ksType.isNodeData(value, value => value === NodeKind.Identifier)) || __ksType.isNodeData(value, NodeKind.__ks_eq_Expression) || Type.isNull(value)});
			}
			return true;
		}}),
		isEvent: (value, mapper, filter) => Type.isDexObject(value, 1, 0, {ok: variant => {
			if(!Type.isBoolean(variant)) {
				return false;
			}
			if(filter && !filter(variant)) {
				return false;
			}
			if(variant) {
				return __ksType.isEvent.__1(value, mapper);
			}
			else {
				return __ksType.isEvent.__0(value);
			}
		}})
	};
	__ksType.isEvent.__0 = Type.isObject;
	__ksType.isEvent.__1 = (value, mapper) => Type.isDexObject(value, 0, 0, {value: mapper[0], line: Type.isNumber, column: Type.isNumber});
	const NodeKind = Helper.enum(Number, 0, "Identifier", 0, "RegularExpression", 1, "TypeReference", 2);
	NodeKind.__ks_eq_Expression = value => value === NodeKind.Identifier || value === NodeKind.RegularExpression;
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(subtypes, {line, column}) {
		if(subtypes === void 0) {
			subtypes = null;
		}
		const result = (() => {
			const o = new OBJ();
			o.kind = NodeKind.TypeReference;
			o.line = line;
			o.column = column;
			return o;
		})();
		if(Type.isValue(subtypes)) {
			if(Type.isArray(subtypes.value)) {
				result.subtypes = Helper.mapArray(subtypes.value, function(subtype) {
					return subtype.value;
				});
			}
			else {
				result.subtypes = subtypes.value;
			}
		}
		return result;
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => __ksType.isEvent(value, [value => Type.isArray(value, value => __ksType.isEvent(value, [value => __ksType.isNodeData(value, value => value === NodeKind.Identifier)], value => value)) || __ksType.isNodeData(value, NodeKind.__ks_eq_Expression)], value => value) || Type.isNull(value);
		const t1 = __ksType.isPosition;
		if(args.length === 2) {
			if(t0(args[0]) && t1(args[1])) {
				return foobar.__ks_0.call(that, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	};
};