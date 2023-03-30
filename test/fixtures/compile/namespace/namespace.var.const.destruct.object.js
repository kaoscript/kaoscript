const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function min() {
		return min.__ks_rt(this, arguments);
	};
	min.__ks_0 = function() {
		return (() => {
			const o = new OBJ();
			o.gender = "female";
			o.age = 24;
			return o;
		})();
	};
	min.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return min.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
	let foo = Helper.namespace(function() {
		let  __ks_0 = min.__ks_0();
		Helper.assertDexObject(__ks_0, 1, 0, {gender: Type.isValue, age: Type.isValue});
		const {gender, age} = __ks_0;
		return {
			gender,
			age
		};
	});
	console.log(foo.age);
	console.log(Helper.toString(foo.gender));
};