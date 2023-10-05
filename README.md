# Keychain

A Swift client for saving, retrieving or removing values from `Keychain`.
                            
```swift
import Keychain

let keychain = Keychain()

do {
  // get token...
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

The client comes also with a helper for handling `Public-Key (Asymmetric) Cryptography` for encrypting and decrypting data.

```swift
do {
  let text = "Super secret text"
  let cypher = Keychain.Cypher("com.cypher.mykey")
  let encryptedData = try cypher.encrypt(text)
  let decryptedData = try cypher.decrypt(encryptedData)
  let result = String(data: decryptedData, encoding: .utf8)
} catch {
  // handle error
}
```
