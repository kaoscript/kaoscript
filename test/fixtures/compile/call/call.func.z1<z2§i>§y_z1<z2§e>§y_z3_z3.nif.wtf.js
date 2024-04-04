const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ksType = {
		isPosition: value => Type.isDexObject(value, 1, 0, {line: Type.isNumber, column: Type.isNumber}),
		isRange: value => Type.isDexObject(value, 1, 0, {start: __ksType.isPosition, end: __ksType.isPosition}),
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
			if(variant === NodeKind.Identifier) {
				return Type.isDexObject(value, 0, 0, {name: Type.isString});
			}
			return true;
		}}),
		isEvent: (value, mapper, filter) => __ksType.isRange(value) && Type.isDexObject(value, 1, 0, {ok: variant => {
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
	const NodeKind = Helper.enum(Number, 0, "ArrayBinding", 0, "ObjectBinding", 1, "Identifier", 2);
	NodeKind.__ks_eq_Expression = value => value === NodeKind.ArrayBinding || value === NodeKind.ObjectBinding || value === NodeKind.Identifier;
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(name, value) {
		quxbaz.__ks_0(name, value, name, value);
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => __ksType.isEvent(value, [value => __ksType.isNodeData(value, 0, NodeKind.__ks_eq_Expression)], value => value);
		if(args.length === 2) {
			if(t0(args[0]) && t0(args[1])) {
				return foobar.__ks_0.call(that, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	};
	function quxbaz() {
		return quxbaz.__ks_rt(this, arguments);
	};
	quxbaz.__ks_0 = function(name, value, {start}, {end}) {
	};
	quxbaz.__ks_rt = function(that, args) {
		const t0 = value => __ksType.isEvent(value, [value => __ksType.isNodeData(value, 0, value => value === NodeKind.Identifier)], value => value);
		const t1 = value => __ksType.isEvent(value, [value => __ksType.isNodeData(value, 0, NodeKind.__ks_eq_Expression)], value => value);
		const t2 = __ksType.isRange;
		if(args.length === 4) {
			if(t0(args[0]) && t1(args[1]) && t2(args[2]) && t2(args[3])) {
				return quxbaz.__ks_0.call(that, args[0], args[1], args[2], args[3]);
			}
		}
		throw Helper.badArgs();
	};
};