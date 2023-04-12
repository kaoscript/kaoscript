#![error(ignore(NotImplementedError, NotSupportedError))]

extern sealed class Error

class NotImplementedError extends Error {
}

class NotSupportedError extends Error {
}

throw NotImplementedError.new()