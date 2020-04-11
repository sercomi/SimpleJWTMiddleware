import Foundation
import Vapor
import JWT

public struct Payload: JWTPayload {
    public let firstname: String?
    public let lastname: String?
    public let email: String
    public let id: UUID
    public let status: Int = 0
    public let exp: String
    public let iat: String

    public init(id: UUID, email: String) {
        self.id = id
        self.email = email
        self.firstname = nil
        self.lastname = nil
        self.exp = String(Date().addingTimeInterval(60*60*24).timeIntervalSince1970)
        self.iat = String(Date().timeIntervalSince1970)
    }

   public func verify(using signer: JWTSigner) throws {
        let expiration = Date(timeIntervalSince1970: Double(self.exp)!)
        try ExpirationClaim(value: expiration).verifyNotExpired()
    }
}
