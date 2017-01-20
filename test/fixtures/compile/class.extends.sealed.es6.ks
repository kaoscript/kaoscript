extern sealed class Error

class NotImplementedError extends Error {
	$create(message = 'Not Implemented') {
		this.message = message
	}
}