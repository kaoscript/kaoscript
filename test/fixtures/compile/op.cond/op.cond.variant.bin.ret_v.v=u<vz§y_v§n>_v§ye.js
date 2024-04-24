const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ksType = {
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
		}}),
		isSchoolPerson: value => Type.isDexObject(value, 1, 0, {name: Type.isString})
	};
	__ksType.isEvent.__0 = Type.isObject;
	__ksType.isEvent.__1 = (value, mapper) => Type.isDexObject(value, 0, 0, {value: mapper[0]});
	const NO = (() => {
		const o = new OBJ();
		o.ok = false;
		return o;
	})();
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(test) {
		let result = NO;
		if(test) {
			result = loadJohn.__ks_0();
		}
		return result.ok ? result : loadJohn.__ks_0();
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isBoolean;
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