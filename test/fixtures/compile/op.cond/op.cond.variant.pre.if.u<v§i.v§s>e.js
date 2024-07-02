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
	const NO = (() => {
		const o = new OBJ();
		o.ok = false;
		return o;
	})();
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(test) {
		let e = NO;
		if(test() === true) {
			e = getString.__ks_0();
		}
		else {
			e = getNumber.__ks_0();
		}
		if(e.ok) {
		}
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	function getString() {
		return getString.__ks_rt(this, arguments);
	};
	getString.__ks_0 = function() {
		return (() => {
			const o = new OBJ();
			o.ok = true;
			o.value = "Hello!";
			return o;
		})();
	};
	getString.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return getString.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
	function getNumber() {
		return getNumber.__ks_rt(this, arguments);
	};
	getNumber.__ks_0 = function() {
		return (() => {
			const o = new OBJ();
			o.ok = true;
			o.value = 42;
			return o;
		})();
	};
	getNumber.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return getNumber.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
};