const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const NodeKind = Helper.enum(Number, 0, "ArrayBinding", 0, "ObjectBinding", 1, "Identifier", 2);
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
		if(variant === NodeKind.ArrayBinding) {
			return Type.isDexObject(value, 0, 0, {alias: value => NodeData.is(value, cast, value => value === NodeKind.Identifier) || Type.isNull(value)});
		}
		if(variant === NodeKind.Identifier) {
			return Type.isDexObject(value, 0, 0, {name: Type.isString});
		}
		if(variant === NodeKind.ObjectBinding) {
			return Type.isDexObject(value, 0, 0, {alias: value => NodeData.is(value, cast, value => value === NodeKind.Identifier) || Type.isNull(value)});
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
	function fooobar() {
		return fooobar.__ks_rt(this, arguments);
	};
	fooobar.__ks_0 = function(event) {
		if(event.value.kind === NodeKind.Identifier) {
			const alias = event;
			event = reqBinding.__ks_0();
			event.value.alias = alias.value;
		}
	};
	fooobar.__ks_rt = function(that, args) {
		const t0 = value => Event.is(value, [value => NodeData.is(value, 0, value => value === NodeKind.Identifier || value === NodeKind.ArrayBinding || value === NodeKind.ObjectBinding)], value => value);
		if(args.length === 1) {
			if(t0(args[0])) {
				return fooobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	function reqBinding() {
		return reqBinding.__ks_rt(this, arguments);
	};
	reqBinding.__ks_0 = function() {
		return (() => {
			const o = new OBJ();
			o.ok = true;
			o.value = (() => {
				const o = new OBJ();
				o.kind = NodeKind.ArrayBinding;
				return o;
			})();
			return o;
		})();
	};
	reqBinding.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return reqBinding.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
};