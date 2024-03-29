const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Event = Helper.struct(function(ok, value) {
		const _ = new OBJ();
		_.ok = ok;
		_.value = value;
		return _;
	}, function(__ks_new, args) {
		const t0 = Type.isBoolean;
		const t1 = Type.isValue;
		if(args.length === 2) {
			if(t0(args[0]) && t1(args[1])) {
				return __ks_new(args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	}, function(__ks_new, item) {
		if(Type.isStructInstance(item, Event)) {
			return item;
		}
		if(!Type.isObject(item)) {
			return null;
		}
		const args = [];
		let arg;
		if(!Type.isBoolean(arg = item.ok)) {
			return null;
		}
		args[0] = arg;
		if(!Type.isValue(arg = item.value)) {
			return null;
		}
		args[1] = arg;
		return __ks_new.call(null, args);
	});
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function() {
		let event;
		if((event = quxbaz.__ks_0()).ok === true) {
		}
	};
	foobar.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return foobar.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
	function quxbaz() {
		return quxbaz.__ks_rt(this, arguments);
	};
	quxbaz.__ks_0 = function() {
	};
	quxbaz.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return quxbaz.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
};