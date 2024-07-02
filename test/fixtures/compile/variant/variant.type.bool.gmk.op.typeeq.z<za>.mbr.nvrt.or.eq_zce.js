const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const NodeKind = Helper.enum(Number, 0, "Identifier", 0, "ObjectComprehension", 1);
	NodeKind.__ks_eq_Expression = value => value === NodeKind.ObjectComprehension || value === NodeKind.Identifier;
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
		if(variant === NodeKind.Identifier) {
			return Type.isDexObject(value, 0, 0, {name: Type.isString});
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
	Event.isTrue = (value, mapper) => Type.isDexObject(value, 0, 0, {value: mapper[0]});
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(data) {
		if(!data.ok || (data.value.kind === NodeKind.ObjectComprehension)) {
		}
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Event.is(value, [value => NodeData.is(value, 0, NodeKind.__ks_eq_Expression)]);
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};