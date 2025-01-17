import Foundation
import BigInt
import Cryptor

/// Creates the salted verification key based on a user's username and
/// password. Only the salt and verification key need to be stored on the
/// server, there's no need to keep the plain-text password. 
///
/// Keep the verification key private, as it can be used to brute-force 
/// the password from.
///
/// - Parameters:
///   - username: user's username
///   - password: user's password
///   - salt: (optional) custom salt value; if providing a salt, make sure to
///       provide a good random salt of at least 16 bytes. Default is to
///       generate a salt of 16 bytes.
///   - group: `Group` parameters; default is 2048-bits group.
///   - algorithm: which `Digest.Algorithm` to use; default is SHA1.
/// - Returns: salt (s) and verification key (v)
public func createSaltedVerificationKey(
    username: String,
    password: String,
    salt: Data? = nil,
    group: Group = .N2048,
    algorithm: Digest.Algorithm = .sha1)
    -> (salt: Data, verificationKey: Data)
{
    var bytes = try! Random.generate(byteCount: 16)
    let salt = salt ?? Data(bytes: &bytes, count: 16)
    let x = calculate_x(algorithm: algorithm, salt: salt, username: username, password: password)
    return createSaltedVerificationKey(from: x, salt: salt, group: group)
}

/// Creates the salted verification key based on a precomputed SRP x value.
/// Only the salt and verification key need to be stored on the
/// server, there's no need to keep the plain-text password.
///
/// Keep the verification key private, as it can be used to brute-force
/// the password from.
///
/// - Parameters:
///   - x: precomputed SRP x
///   - salt: (optional) custom salt value; if providing a salt, make sure to
///       provide a good random salt of at least 16 bytes. Default is to
///       generate a salt of 16 bytes.
///   - group: `Group` parameters; default is 2048-bits group.
/// - Returns: salt (s) and verification key (v)
public func createSaltedVerificationKey(
    from x: Data,
    salt: Data? = nil,
    group: Group = .N2048)
    -> (salt: Data, verificationKey: Data)
{
    return createSaltedVerificationKey(from: BigUInt(x), salt: salt, group: group)
}

func createSaltedVerificationKey(
    from x: BigUInt,
    salt: Data? = nil,
    group: Group = .N2048)
    -> (salt: Data, verificationKey: Data)
{
    var bytes = try! Random.generate(byteCount: 16)
    let salt = salt ?? Data(bytes: &bytes, count: 16)
    let v = calculate_v(group: group, x: x)
    return (salt, v.serialize())
}

func pad(_ data: Data, to size: Int) -> Data {
    precondition(size >= data.count, "Negative padding not possible")
    return Data(count: size - data.count) + data
}

//u = H(PAD(A) | PAD(B))
func calculate_u(group: Group, algorithm: Digest.Algorithm, A: Data, B: Data) -> BigUInt {
    let H = Digest.hasher(algorithm)
    let size = group.N.serialize().count
    return BigUInt(H(pad(A, to: size) + pad(B, to: size)))
}

//M1 = H(H(N) XOR H(g) | H(I) | s | A | B | K)
func calculate_M(group: Group, algorithm: Digest.Algorithm, username: String, salt: Data, A: Data, B: Data, K: Data) -> Data {
    let H = Digest.hasher(algorithm)
    let HN_xor_Hg = (H(group.N.serialize()) ^ H(group.g.serialize()))!
    let HI = H(username.data(using: .utf8)!)
    return H(HN_xor_Hg + HI + salt + A + B + K)
}

//HAMK = H(A | M | K)
func calculate_HAMK(algorithm: Digest.Algorithm, A: Data, M: Data, K: Data) -> Data {
    let H = Digest.hasher(algorithm)
    return H(A + M + K)
}

//k = H(N | PAD(g))
func calculate_k(group: Group, algorithm: Digest.Algorithm) -> BigUInt {
    let H = Digest.hasher(algorithm)
    let size = group.N.serialize().count
    return BigUInt(H(group.N.serialize() + pad(group.g.serialize(), to: size)))
}

//x = H(s | H(I | ":" | P))
func calculate_x(algorithm: Digest.Algorithm, salt: Data, username: String, password: String) -> BigUInt {
    let H = Digest.hasher(algorithm)
    let hash1 = "\(username):\(password)".data(using: .utf8)!
    let hash2 = H(hash1)
    let hash3 = (salt + hash2).hexadecimal
    let hash4 = H(hash3.data(using: .utf8)!)
    let hash = BigUInt(hash4.hexadecimal, radix: 16)!
    return hash
}

// v = g^x % N
func calculate_v(group: Group, x: BigUInt) -> BigUInt {
    let v1 = group.g.power(x, modulus: group.N)
    let v = BigUInt(v1.serialize().hexadecimal, radix: 16)!
    return v
}
