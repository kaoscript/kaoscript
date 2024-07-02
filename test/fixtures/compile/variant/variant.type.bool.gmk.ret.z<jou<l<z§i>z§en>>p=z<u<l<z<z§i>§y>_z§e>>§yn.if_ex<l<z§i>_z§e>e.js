const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Position = Helper.alias(value => Type.isDexObject(value, 1, 0, {line: Type.isNumber, column: Type.isNumber}));
	const NodeKind = Helper.enum(Number, 0, "Identifier", 0, "RegularExpression", 1, "TypeReference", 2);
	NodeKind.__ks_eq_Expression = value => value === NodeKind.Identifier || value === NodeKind.RegularExpression;
	const NodeData = Helper.alias((value, cast, filter) => Position.is(value) && Type.isDexObject(value, 1, 0, {kind: variant => {
		if(cast) {
			if((variant = NodeKind(variant)) === null) {
				return false;
			}
			value["kind"] = variant;
		}
		else if(!Type.isEnumInstance(variant, NodeKind)) {
			return false;
		}
		if(filter && !filter(variant)) {
			return false;
		}
		if(variant === NodeKind.TypeReference) {
			return Type.isDexObject(value, 0, 0, {subtypes: value => Type.isArray(value, value => NodeData.is(value, cast, value => value === NodeKind.Identifier)) || NodeData.is(value, cast, NodeKind.__ks_eq_Expression) || Type.isNull(value)});
		}
		return true;
	}}));
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
	Event.isFalse = Type.isObject;
	Event.isTrue = (value, mapper) => Type.isDexObject(value, 0, 0, {value: mapper[0], line: Type.isNumber, column: Type.isNumber});
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
				result.subtypes = (() => {
					const a = [];
					for(let __ks_1 = 0, __ks_0 = subtypes.value.length, subtype; __ks_1 < __ks_0; ++__ks_1) {
						subtype = subtypes.value[__ks_1];
						a.push(subtype.value);
					}
					return a;
				})();
			}
			else {
				result.subtypes = subtypes.value;
			}
		}
		return result;
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Event.is(value, [value => Type.isArray(value, value => Event.is(value, [value => NodeData.is(value, 0, value => value === NodeKind.Identifier)], value => value)) || NodeData.is(value, 0, NodeKind.__ks_eq_Expression)], value => value) || Type.isNull(value);
		const t1 = Position.is;
		if(args.length === 2) {
			if(t0(args[0]) && t1(args[1])) {
				return foobar.__ks_0.call(that, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	};
};