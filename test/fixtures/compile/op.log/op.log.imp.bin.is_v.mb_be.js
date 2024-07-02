const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Kind = Helper.enum(Number, 0, "Foobar", 0);
	const Foobar = Helper.alias((value, cast, filter) => Type.isDexObject(value, 1, 0, {kind: variant => {
		if(cast) {
			if((variant = Kind(variant)) === null) {
				return false;
			}
			value["kind"] = variant;
		}
		else if(!Type.isEnumInstance(variant, Kind)) {
			return false;
		}
		if(filter && !filter(variant)) {
			return false;
		}
		if(variant === Kind.Foobar) {
			return Type.isDexObject(value, 0, 0, {flag: Type.isBoolean});
		}
		return true;
	}, name: Type.isString}));
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(value) {
		if(!(value.kind === Kind.Foobar) || value.flag) {
			console.log(value.name);
		}
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Foobar.is;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};