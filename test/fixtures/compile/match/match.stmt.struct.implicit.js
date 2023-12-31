const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Foobar = Helper.struct(function(argument, from) {
		const _ = new OBJ();
		_.argument = argument;
		_.from = from;
		return _;
	}, function(__ks_new, args) {
		const t0 = Type.isString;
		if(args.length === 2) {
			if(t0(args[0]) && t0(args[1])) {
				return __ks_new(args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	}, function(__ks_new, item) {
		if(Type.isStructInstance(item, Foobar)) {
			return item;
		}
		if(!Type.isObject(item)) {
			return null;
		}
		const args = [];
		let arg;
		if(!Type.isString(arg = item.argument)) {
			return null;
		}
		args[0] = arg;
		if(!Type.isString(arg = item.from)) {
			return null;
		}
		args[1] = arg;
		return __ks_new.call(null, args);
	});
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(value) {
		if(value === void 0) {
			value = null;
		}
		if(Type.isNumber(value)) {
		}
		else if(Type.isStructInstance(value, Foobar)) {
			console.log(value.from + ": " + value.argument);
		}
	};
	foobar.__ks_rt = function(that, args) {
		if(args.length === 1) {
			return foobar.__ks_0.call(that, args[0]);
		}
		throw Helper.badArgs();
	};
};