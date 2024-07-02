const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Position = Helper.alias(value => Type.isDexObject(value, 1, 0, {line: Type.isNumber, column: Type.isNumber}));
	const NodeKind = Helper.enum(Number, 0, "Identifier", 0, "RegularExpression", 1, "TypeReference", 2);
	NodeKind.__ks_eq_Expression = value => value === NodeKind.Identifier || value === NodeKind.RegularExpression;
	const NodeData = Helper.alias((value, cast, filter) => Type.isDexObject(value, 1, 0, {kind: variant => {
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
	return {
		Position,
		NodeKind,
		NodeData
	};
};