const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Position = Helper.alias(value => Type.isDexObject(value, 1, 0, {line: Type.isNumber, column: Type.isNumber}));
	const NodeKind = Helper.enum(Number, 0, "Block", 0, "ExpressionStatement", 1, "Identifier", 2, "ReturnStatement", 3, "UnlessStatement", 4);
	NodeKind.__ks_eq_Statement = value => value === NodeKind.ExpressionStatement || value === NodeKind.ReturnStatement || value === NodeKind.UnlessStatement;
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
		if(variant === NodeKind.ExpressionStatement) {
			return Type.isDexObject(value, 0, 0, {expression: value => NodeData.is(value, cast, value => value === NodeKind.Identifier)});
		}
		if(variant === NodeKind.UnlessStatement) {
			return Type.isDexObject(value, 0, 0, {condition: value => NodeData.is(value, cast, value => value === NodeKind.Identifier), whenFalse: value => NodeData.is(value, cast, value => value === NodeKind.Block || value === NodeKind.ExpressionStatement || value === NodeKind.ReturnStatement)});
		}
		return true;
	}, start: Position.is, end: Position.is}));
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
	Event.isTrue = (value, mapper) => Type.isDexObject(value, 0, 0, {value: mapper[0]});
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(statement) {
		if(statement.value.kind === NodeKind.UnlessStatement) {
			const {condition, whenFalse} = statement.value;
		}
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Event.is(value, [NodeData.is], value => value);
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};