module.exports = function(Array, __ks_Array, Class, Function, __ks_Function, Object, __ks_Object, Type) {
	function age() {
		return 15;
	}
	function main() {
		let __ks_0 = age();
		if(__ks_0 === 0) {
			console.log("I'm not born yet I guess");
		}
		else if(__ks_0 >= 1 && __ks_0 <= 12) {
			let n = __ks_0;
			console.log("I'm a child of age " + n);
		}
		else if(__ks_0 >= 13 && __ks_0 <= 19) {
			let n = __ks_0;
			console.log("I'm a teen of age " + n);
		}
		else if() {
			let n = __ks_0;
			console.log("I'm an old person of age " + n);
		}
	}
}