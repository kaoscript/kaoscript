module.exports = function(expect) {
	const __ks_Date = {};
	const d = new Date();
	expect(d.culture).to.not.exist;
	return {
		__ks_Date
	};
};