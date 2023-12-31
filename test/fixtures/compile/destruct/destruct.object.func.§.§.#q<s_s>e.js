const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Foobar = Helper.struct(function(x, y) {
		const _ = new OBJ();
		_.x = x;
		_.y = y;
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
		if(!Type.isString(arg = item.x)) {
			return null;
		}
		args[0] = arg;
		if(!Type.isString(arg = item.y)) {
			return null;
		}
		args[1] = arg;
		return __ks_new.call(null, args);
	});
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function({x, y}) {
		console.log(x + "." + y);
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isStructInstance(value, Foobar);
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};