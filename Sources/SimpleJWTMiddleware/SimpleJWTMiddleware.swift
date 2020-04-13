import Vapor
import JWT

public final class SimpleJWTMiddleware: Middleware {
    public init() { }

    public func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        
        guard let token = request.headers.bearerAuthorization?.token.utf8 else {
            return request.eventLoop.makeFailedFuture(Abort(.unauthorized, reason: "Missing authorization bearer header"))
        }

        do {
            request.payload = try request.jwt.verify(Array(token), as: Payload.self)
        } catch let JWTError.claimVerificationFailure(name: name, reason: reason) {
            request.logger.error("JWT Verification Failure: \(name), \(reason)")
            return request.eventLoop.makeFailedFuture(JWTError.claimVerificationFailure(name: name, reason: reason))
        } catch let error {
            return request.eventLoop.makeFailedFuture(error)
        }

        return next.respond(to: request)
    }

}

private struct SimpleJWTMiddlewareKey: StorageKey {
    typealias Value = Payload
}

extension Request {
    public var loggedIn: Bool {
        if (self.storage[SimpleJWTMiddlewareKey.self] != nil) {
            return true
        }
        return false
    }
    public var payload: Payload {
        get { self.storage[SimpleJWTMiddlewareKey.self]! }
        set { self.storage[SimpleJWTMiddlewareKey.self] = newValue }
    }
}
