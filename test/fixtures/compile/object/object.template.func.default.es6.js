module.exports = function() {
	let x = "y";
	let foo = {
		[x]() {
			return 42;
		}
	};
};