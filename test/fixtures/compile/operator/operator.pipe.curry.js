const {Helper, Operator, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function process() {
		return process.__ks_rt(this, arguments);
	};
	process.__ks_0 = function(elements) {
		return filter(map(elements, Helper.curry((fn, ...args) => {
			const t0 = Type.isValue;
			if(args.length === 1) {
				if(t0(args[0])) {
					return fn[0](args[0]);
				}
			}
			throw Helper.badArgs();
		}, (__ks_0) => add.__ks_0(__ks_0, 1))), Helper.curry((fn, ...args) => {
			const t0 = Type.isValue;
			if(args.length === 1) {
				if(t0(args[0])) {
					return fn[0](args[0]);
				}
			}
			throw Helper.badArgs();
		}, (__ks_0) => greaterThan.__ks_0(__ks_0, 5)));
	};
	process.__ks_rt = function(that, args) {
		const t0 = Type.isArray;
		if(args.length === 1) {
			if(t0(args[0])) {
				return process.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	function add() {
		return add.__ks_rt(this, arguments);
	};
	add.__ks_0 = function(x, y) {
		return Operator.add(x, y);
	};
	add.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 2) {
			if(t0(args[0]) && t0(args[1])) {
				return add.__ks_0.call(that, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	};
	function greaterThan() {
		return greaterThan.__ks_rt(this, arguments);
	};
	greaterThan.__ks_0 = function(x, y) {
		return Operator.gt(x, y);
	};
	greaterThan.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 2) {
			if(t0(args[0]) && t0(args[1])) {
				return greaterThan.__ks_0.call(that, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	};
};