#![error(ignore(Exception))]

extern sealed class Error

class Exception extends Error {
}

throw new Error()