module.exports = function() {
	console.log(foobar());
	return {
		foobar: foobar
	};
};