const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ksType = {
		isPosition: value => Type.isDexObject(value, 1, 0, {line: Type.isNumber, column: Type.isNumber}),
		isNodeData: (value, cast, filter) => __ksType.isPosition(value) && Type.isDexObject(value, 1, 0, {kind: variant => {
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
				return Type.isDexObject(value, 0, 0, {subtypes: value => Type.isArray(value, value => __ksType.isNodeData(value, cast, value => value === NodeKind.Identifier)) || __ksType.isNodeData(value, cast, NodeKind.__ks_eq_Expression) || Type.isNull(value)});
			}
			return true;
		}})
	};
	const NodeKind = Helper.enum(Number, 0, "Identifier", 0, "RegularExpression", 1, "TypeReference", 2);
	NodeKind.__ks_eq_Expression = value => value === NodeKind.Identifier || value === NodeKind.RegularExpression;
	return {
		NodeKind,
		__ksType: [__ksType.isPosition, __ksType.isNodeData]
	};
};