module.exports = function() {
	function foo(...args) {
		for(let i = 0, __ks_0 = args.length; i < __ks_0; ++i) {
			console.log(args[i]);
		}
		let j = 42;
		let __ks_0;
		for(j = 0, __ks_0 = args.length; j < __ks_0; ++j) {
			console.log(args[j]);
		}
	}
};