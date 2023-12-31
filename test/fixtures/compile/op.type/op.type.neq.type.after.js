const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(result) {
		if(!Type.isStructInstance(result, NoResult)) {
		}
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isStructInstance(value, Result) || Type.isStructInstance(value, NoResult);
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	const Result = Helper.struct(function(value) {
		if(value === void 0) {
			value = null;
		}
		const _ = new OBJ();
		_.value = value;
		return _;
	}, function(__ks_new, args) {
		if(args.length === 1) {
			return __ks_new(args[0]);
		}
		throw Helper.badArgs();
	}, function(__ks_new, item) {
		if(Type.isStructInstance(item, Result)) {
			return item;
		}
		if(!Type.isObject(item)) {
			return null;
		}
		const args = [];
		let arg;
		if(!true) {
			return null;
		}
		args[0] = arg;
		return __ks_new.call(null, args);
	});
	const NoResult = Helper.struct(function(message) {
		if(message === void 0) {
			message = null;
		}
		const _ = new OBJ();
		_.message = message;
		return _;
	}, function(__ks_new, args) {
		const t0 = value => Type.isString(value) || Type.isNull(value);
		if(args.length === 1) {
			if(t0(args[0])) {
				return __ks_new(args[0]);
			}
		}
		throw Helper.badArgs();
	}, function(__ks_new, item) {
		if(Type.isStructInstance(item, NoResult)) {
			return item;
		}
		if(!Type.isObject(item)) {
			return null;
		}
		const args = [];
		let arg;
		if(!Type.isString(arg = item.message) || Type.isNull(arg = item.message)) {
			return null;
		}
		args[0] = arg;
		return __ks_new.call(null, args);
	});
};