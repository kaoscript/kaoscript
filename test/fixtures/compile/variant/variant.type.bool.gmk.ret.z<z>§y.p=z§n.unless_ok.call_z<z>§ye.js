const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
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
	const SchoolPerson = Helper.alias(value => Type.isDexObject(value, 1, 0, {name: Type.isString}));
	const NO = (() => {
		const o = new OBJ();
		o.ok = false;
		return o;
	})();
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(result) {
		if(!result.ok) {
			result = loadJohn.__ks_0();
		}
		return Helper.assert(result, "\"Event<SchoolPerson>(true)\"", 0, value => Event.is(value, [SchoolPerson.is], value => value));
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Event.is(value, [Type.any]);
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	function loadJohn() {
		return loadJohn.__ks_rt(this, arguments);
	};
	loadJohn.__ks_0 = function() {
		return (() => {
			const o = new OBJ();
			o.ok = true;
			o.value = (() => {
				const o = new OBJ();
				o.name = "John";
				return o;
			})();
			return o;
		})();
	};
	loadJohn.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return loadJohn.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
};