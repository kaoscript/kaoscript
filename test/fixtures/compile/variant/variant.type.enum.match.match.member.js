const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ksType = {
		isNodeData: (value, cast, filter) => Type.isDexObject(value, 1, 0, {kind: variant => {
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
				return Type.isDexObject(value, 0, 0, {expression: value => __ksType.isNodeData(value, cast, value => value === NodeKind.Identifier)});
			}
			if(variant === NodeKind.UnlessStatement) {
				return Type.isDexObject(value, 0, 0, {condition: value => __ksType.isNodeData(value, cast, value => value === NodeKind.Identifier), whenFalse: value => __ksType.isNodeData(value, cast, value => value === NodeKind.Block || value === NodeKind.ExpressionStatement || value === NodeKind.ReturnStatement)});
			}
			return true;
		}})
	};
	const NodeKind = Helper.enum(Number, 0, "Block", 0, "ExpressionStatement", 1, "Identifier", 2, "ReturnStatement", 3, "UnlessStatement", 4);
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(data) {
		if(data.kind === NodeKind.UnlessStatement) {
			let __ks_0 = data.whenFalse;
			if(__ks_0.kind === NodeKind.ExpressionStatement) {
				console.log(data.whenFalse.expression);
			}
		}
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = __ksType.isNodeData;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};