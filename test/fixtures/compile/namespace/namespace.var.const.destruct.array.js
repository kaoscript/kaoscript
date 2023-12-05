const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function min() {
		return min.__ks_rt(this, arguments);
	};
	min.__ks_0 = function() {
		return ["female", 24];
	};
	min.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return min.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
	let foo = Helper.namespace(function() {
		let  __ks_0 = min.__ks_0();
		Helper.assertDexArray(__ks_0, 1, 2, 0, 0, [Type.isValue, Type.isValue]);
		const [gender, age] = __ks_0;
		return {
			gender,
			age
		};
	});
	console.log(foo.age);
	console.log(Helper.toString(foo.gender));
};