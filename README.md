# sonar-dummy-maven

A sample project used for showcase and testing purposes

This project uses **Maven** and is the public part sync
of [sonar-dummy-maven-enterprise](https://github.com/SonarSource/sonar-dummy-maven-enterprise) private repository.

It is used to test that the sync of public/private repository code is working properly.

## Text encryption

The Java 21 utility uses JDK cryptography APIs. Run `mvn --batch-mode verify` to build
and test it. The public Cirrus build runs this command on Java 21. The private CI
selection and repository synchronization remain unchanged.

```java
import com.sonarsource.dummy.crypto.AsymmetricEncryption;
import java.security.KeyPairGenerator;

var generator = KeyPairGenerator.getInstance("RSA");
generator.initialize(3072);
var keys = generator.generateKeyPair();
var ciphertext = AsymmetricEncryption.encrypt("Hello, 世界", keys.getPublic());
var plaintext = AsymmetricEncryption.decrypt(ciphertext, keys.getPrivate());
```

Both methods are static and declare `GeneralSecurityException`. Null arguments
throw `NullPointerException`. Non-RSA keys and RSA keys below 2048 bits throw
`IllegalArgumentException`. Malformed envelopes, unsupported versions, wrong keys,
and authentication failures throw `GeneralSecurityException("Decryption failed")`
without a provider-specific cause or partial plaintext. Encryption can also throw
`GeneralSecurityException` if the provider cannot perform an operation.

Each encryption generates an AES-256 key and a 12-byte random nonce. AES-GCM uses a
128-bit tag. RSA-OAEP wraps the AES key with explicit SHA-256 and MGF1-SHA-256
parameters. Empty text, Unicode, and text beyond the direct RSA size limit are
supported. Repeated encryption produces different ciphertext.

The version-1 envelope uses standard Base64 over these binary fields, in order:

| Field | Size |
| --- | --- |
| ASCII marker `ASEN` | 4 bytes |
| Version `1` | 1 byte |
| Wrapped-key length, big-endian | 4 bytes |
| RSA-wrapped AES key | RSA modulus size in bytes |
| GCM nonce | 12 bytes |
| GCM ciphertext and tag | UTF-8 plaintext size plus 16 bytes |

The first nine bytes are authenticated as additional data. The wrapped-key length
must match the supplied RSA key. Decryption validates lengths before extracting
fields and authenticates all ciphertext before returning plaintext.

Callers generate and protect the key pair. Do not log plaintext, private keys, or
unwrapped AES keys. This utility does not store keys, identify the sender, or
provide forward secrecy. Losing the private key makes ciphertext unrecoverable.
A compromised private key exposes text encrypted for that key. The String API
keeps plaintext in JVM memory and requires the complete message to fit in memory.
Use well-formed Unicode text; Java UTF-8 encoding replaces unpaired surrogates.
The format is new and versioned; future format changes need a compatibility decision.
