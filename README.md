# Keychain client

A Swift client for saving, retrieving or removing values from `Keychain`. The `set(value:forKey:)` and `value(forKey:)` methods are built using generics, so any `Codable` data can be stored.
                            
```swift
import Keychain

do {
  let keychain = Keychain()
  try keychain.set(value: token, forKey: "token")
} catch {
  // handle error
}
```

```swift
do {
  if let token: String? = try keychain.value(forKey: "token") {
    // do something with the token
  }
} catch {
  // handle error
}
```

```swift
do {
  try keychain.remove("token")
} catch {
  // handle error
}
```

The client comes with a helper for handling `Public-Key (Asymmetric) Cryptography` for encrypting and decrypting data. The `Cypher` can use different algorithms and different key data lenghts.

```swift
do {
  let text = "Super secret text"
  let cypher = Keychain.Cypher("com.keychain.cypher.mykey")
  let encryptedData = try cypher.encrypt(text)
  let decryptedData = try cypher.decrypt(encryptedData)
  let result = String(data: decryptedData, encoding: .utf8)
} catch {
  // handle error
}
```
