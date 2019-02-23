module.exports = function() {
	function foo(...args) {
		for(let i = 0, __ks_0 = args.length; i < __ks_0; ++i) {
			console.log(args[i]);
		}
		let j = 42;
		let __ks_1;
		for(j = 0, __ks_1 = args.length; j < __ks_1; ++j) {
			console.log(args[j]);
		}
	}
};