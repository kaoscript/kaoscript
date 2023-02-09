const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(value) {
		let __ks_0 = Type.isObject(value);
		let __ks_1 = ({foo}) => foo === 1;
		let __ks_2 = ({qux}) => !Type.isNull(qux);
		let __ks_3 = ({foo}) => foo === 1;
		let __ks_4 = ({foo}) => !Type.isNull(foo);
		let __ks_5 = ({qux}) => !Type.isNull(qux);
		if(__ks_0 && __ks_1(value) && __ks_0 && __ks_2(value)) {
			let {qux: n} = value;
			console.log(Helper.concatString("qux: ", n));
		}
		else if(__ks_0 && __ks_3(value)) {
			console.log("foo: 1");
		}
		else if(__ks_0 && __ks_4(value)) {
			console.log("has foo");
		}
		else if(__ks_0 && __ks_5(value)) {
			console.log("has qux");
		}
		else if(value.bar() === 0) {
			console.log("bar() == 0");
		}
		else {
			console.log("oops!");
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
};