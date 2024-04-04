const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function getNewScore() {
		return getNewScore.__ks_rt(this, arguments);
	};
	getNewScore.__ks_0 = function(person) {
		const newScore = (Helper.function((score) => {
			return boundScore(0, 100, score);
		}, (that, fn, ...args) => {
			const t0 = Type.isValue;
			if(args.length === 1) {
				if(t0(args[0])) {
					return fn.call(null, args[0]);
				}
			}
			throw Helper.badArgs();
		}))((Helper.function((score) => {
			return add(7, score);
		}, (that, fn, ...args) => {
			const t0 = Type.isValue;
			if(args.length === 1) {
				if(t0(args[0])) {
					return fn.call(null, args[0]);
				}
			}
			throw Helper.badArgs();
		}))(((score) => {
			return __ks_double_1(score);
		})(person.score)));
		return Helper.assertNumber(newScore, 0);
	};
	getNewScore.__ks_rt = function(that, args) {
		const t0 = value => Type.isDexObject(value, 1, 0, {score: Type.isNumber});
		if(args.length === 1) {
			if(t0(args[0])) {
				return getNewScore.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	function add() {
		return add.__ks_rt(this, arguments);
	};
	add.__ks_0 = function(x, y) {
		return x + y;
	};
	add.__ks_rt = function(that, args) {
		const t0 = Type.isNumber;
		if(args.length === 2) {
			if(t0(args[0]) && t0(args[1])) {
				return add.__ks_0.call(that, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	};
	function boundScore() {
		return boundScore.__ks_rt(this, arguments);
	};
	boundScore.__ks_0 = function(min, max, x) {
		if(x < min) {
			return min;
		}
		else if(x > max) {
			return max;
		}
		else {
			return x;
		}
	};
	boundScore.__ks_rt = function(that, args) {
		const t0 = Type.isNumber;
		if(args.length === 3) {
			if(t0(args[0]) && t0(args[1]) && t0(args[2])) {
				return boundScore.__ks_0.call(that, args[0], args[1], args[2]);
			}
		}
		throw Helper.badArgs();
	};
	function __ks_double_1() {
		return __ks_double_1.__ks_rt(this, arguments);
	};
	__ks_double_1.__ks_0 = function(x) {
		return x * 2;
	};
	__ks_double_1.__ks_rt = function(that, args) {
		const t0 = Type.isNumber;
		if(args.length === 1) {
			if(t0(args[0])) {
				return __ks_double_1.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};