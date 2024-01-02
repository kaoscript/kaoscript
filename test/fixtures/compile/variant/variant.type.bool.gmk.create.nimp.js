const {Helper, OBJ, Type} = require("@kaoscript/runtime");
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
	__ksType.isEvent.__1 = (value, mapper) => Type.isDexObject(value, 0, 0, {value: mapper[0]});
	const NodeKind = Helper.enum(Number, 0, "Block", 0, "ExpressionStatement", 1, "Identifier", 2, "ReturnStatement", 3, "UnlessStatement", 4);
	NodeKind.__ks_eq_Statement = value => value === NodeKind.ExpressionStatement || value === NodeKind.ReturnStatement || value === NodeKind.UnlessStatement;
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function() {
		return (() => {
			const o = new OBJ();
			o.ok = true;
			o.value = (() => {
				const o = new OBJ();
				o.kind = NodeKind.ExpressionStatement;
				o.expression = (() => {
					const o = new OBJ();
					o.kind = NodeKind.Identifier;
					return o;
				})();
				return o;
			})();
			return o;
		})();
	};
	foobar.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return foobar.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
};