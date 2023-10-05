# Keychain

A Swift client for saving, retrieving and removing values from `Keychain`.
                            
```swift
import Keychain

let keychain = Keychain()

do {
  // get token...
  try keychain.set(value: token, forKey "token")
} catch {
  // error handling
}
```

```swift
do {
  if let token: String? = try keychain.value(forKey: "token") {
    // do something the token
  }
} catch {
  // error handling
}
```

```swift
do {
  try keychain.remove("token")
} catch {
  // error handling
}
```
