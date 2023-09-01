const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	let Foobar = Helper.namespace(function() {
		function add() {
			return add.__ks_rt(this, arguments);
		};
		add.__ks_0 = function(x, y) {
		};
		add.__ks_rt = function(that, args) {
			const t0 = Type.isString;
			const t1 = Type.isValue;
			if(args.length === 2) {
				if(t0(args[0]) && t1(args[1])) {
					return add.__ks_0.call(that, args[0], args[1]);
				}
			}
			throw Helper.badArgs();
		};
		return {
			add
		};
	});
	function add() {
		return add.__ks_rt(this, arguments);
	};
	add.__ks_0 = function(x, y) {
	};
	add.__ks_rt = function(that, args) {
		const t0 = Type.isString;
		const t1 = Type.isValue;
		if(args.length === 2) {
			if(t0(args[0]) && t1(args[1])) {
				return add.__ks_0.call(that, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	};
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(x) {
		const addZero = () => add(x, 10);
		const addOne = () => Foobar.add(x, 10);
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
};