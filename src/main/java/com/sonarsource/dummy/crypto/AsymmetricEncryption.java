package com.sonarsource.dummy.crypto;

import java.nio.ByteBuffer;
import java.nio.charset.StandardCharsets;
import java.security.GeneralSecurityException;
import java.security.Key;
import java.security.PrivateKey;
import java.security.PublicKey;
import java.security.SecureRandom;
import java.security.interfaces.RSAKey;
import java.security.spec.MGF1ParameterSpec;
import java.util.Arrays;
import java.util.Base64;
import java.util.Objects;
import javax.crypto.Cipher;
import javax.crypto.KeyGenerator;
import javax.crypto.spec.GCMParameterSpec;
import javax.crypto.spec.OAEPParameterSpec;
import javax.crypto.spec.PSource;
import javax.crypto.spec.SecretKeySpec;

/** Hybrid RSA-OAEP/AES-GCM encryption for in-memory UTF-8 text. Callers own all RSA keys. */
public final class AsymmetricEncryption {
  private static final int MAGIC = 0x4153454e; // ASEN
  private static final byte VERSION = 1;
  private static final int HEADER_SIZE = 9;
  private static final int NONCE_SIZE = 12;
  private static final int TAG_SIZE = 16;
  private static final SecureRandom RANDOM = new SecureRandom();
  private static final OAEPParameterSpec OAEP = new OAEPParameterSpec(
    "SHA-256", "MGF1", MGF1ParameterSpec.SHA256, PSource.PSpecified.DEFAULT);

  private AsymmetricEncryption() {
  }

  /**
   * Encrypts text with a fresh AES-256 key and nonce, and wraps that key with RSA-OAEP.
   * @throws NullPointerException for null arguments
   * @throws IllegalArgumentException for a non-RSA key or a key smaller than 2048 bits
   * @throws GeneralSecurityException if encryption fails
   */
  public static String encrypt(String plaintext, PublicKey publicKey) throws GeneralSecurityException {
    Objects.requireNonNull(plaintext, "plaintext");
    validateKey(publicKey);
    KeyGenerator generator = KeyGenerator.getInstance("AES");
    generator.init(256, RANDOM);
    byte[] aesKey = generator.generateKey().getEncoded();
    try {
      Cipher rsa = Cipher.getInstance("RSA/ECB/OAEPWithSHA-256AndMGF1Padding");
      rsa.init(Cipher.ENCRYPT_MODE, publicKey, OAEP, RANDOM);
      byte[] wrappedKey = rsa.doFinal(aesKey);
      byte[] nonce = new byte[NONCE_SIZE];
      RANDOM.nextBytes(nonce);
      byte[] header = ByteBuffer.allocate(HEADER_SIZE)
        .putInt(MAGIC).put(VERSION).putInt(wrappedKey.length).array();
      Cipher aes = Cipher.getInstance("AES/GCM/NoPadding");
      aes.init(Cipher.ENCRYPT_MODE, new SecretKeySpec(aesKey, "AES"), new GCMParameterSpec(128, nonce));
      aes.updateAAD(header);
      byte[] encrypted = aes.doFinal(plaintext.getBytes(StandardCharsets.UTF_8));
      return Base64.getEncoder().encodeToString(ByteBuffer.allocate(
        Math.addExact(HEADER_SIZE + wrappedKey.length + NONCE_SIZE, encrypted.length))
        .put(header).put(wrappedKey).put(nonce).put(encrypted).array());
    } finally {
      Arrays.fill(aesKey, (byte) 0);
    }
  }

  /**
   * Decrypts an authenticated version-1 envelope. No partial plaintext is returned.
   * @throws NullPointerException for null arguments
   * @throws IllegalArgumentException for a non-RSA key or a key smaller than 2048 bits
   * @throws GeneralSecurityException for malformed input, unsupported versions, wrong keys or tampering
   */
  public static String decrypt(String ciphertext, PrivateKey privateKey) throws GeneralSecurityException {
    Objects.requireNonNull(ciphertext, "ciphertext");
    RSAKey rsaKey = validateKey(privateKey);
    byte[] aesKey = null;
    try {
      byte[] envelope = Base64.getDecoder().decode(ciphertext);
      if (envelope.length < HEADER_SIZE + NONCE_SIZE + TAG_SIZE) {
        throw new GeneralSecurityException();
      }
      ByteBuffer input = ByteBuffer.wrap(envelope);
      int magic = input.getInt();
      byte version = input.get();
      int wrappedLength = input.getInt();
      int expectedLength = (rsaKey.getModulus().bitLength() + 7) / 8;
      if (magic != MAGIC || version != VERSION || wrappedLength != expectedLength
        || wrappedLength > input.remaining() - NONCE_SIZE - TAG_SIZE) {
        throw new GeneralSecurityException();
      }
      byte[] wrappedKey = new byte[wrappedLength];
      input.get(wrappedKey);
      byte[] nonce = new byte[NONCE_SIZE];
      input.get(nonce);
      Cipher rsa = Cipher.getInstance("RSA/ECB/OAEPWithSHA-256AndMGF1Padding");
      rsa.init(Cipher.DECRYPT_MODE, privateKey, OAEP);
      aesKey = rsa.doFinal(wrappedKey);
      if (aesKey.length != 32) {
        throw new GeneralSecurityException();
      }
      Cipher aes = Cipher.getInstance("AES/GCM/NoPadding");
      aes.init(Cipher.DECRYPT_MODE, new SecretKeySpec(aesKey, "AES"), new GCMParameterSpec(128, nonce));
      aes.updateAAD(envelope, 0, HEADER_SIZE);
      return new String(aes.doFinal(envelope, input.position(), input.remaining()), StandardCharsets.UTF_8);
    } catch (GeneralSecurityException | IllegalArgumentException e) {
      // Keep provider-specific errors and caller data out of the public failure contract.
      throw new GeneralSecurityException("Decryption failed");
    } finally {
      if (aesKey != null) {
        Arrays.fill(aesKey, (byte) 0);
      }
    }
  }

  private static RSAKey validateKey(Key key) {
    Objects.requireNonNull(key, "key");
    if (!(key instanceof RSAKey rsa) || !"RSA".equals(key.getAlgorithm())
      || rsa.getModulus().bitLength() < 2048) {
      throw new IllegalArgumentException("An RSA key of at least 2048 bits is required");
    }
    return rsa;
  }
}
