const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
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
		return true;
	}}));
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(values) {
		if(values[0].kind === NodeKind.ExpressionStatement) {
		}
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isArray(value, NodeData.is);
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};