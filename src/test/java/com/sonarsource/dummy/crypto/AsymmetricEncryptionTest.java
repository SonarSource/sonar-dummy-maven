package com.sonarsource.dummy.crypto;

import java.nio.ByteBuffer;
import java.security.GeneralSecurityException;
import java.security.KeyPair;
import java.security.KeyPairGenerator;
import java.util.Arrays;
import java.util.Base64;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;

class AsymmetricEncryptionTest {
  private static KeyPair keys;

  @BeforeAll
  static void createKeys() throws Exception {
    keys = rsa(2048);
  }

  @ParameterizedTest
  @ValueSource(strings = {"", "hello", "Été 日本語 😀\n\u0000"})
  void roundTrips(String text) throws Exception {
    assertEquals(text, AsymmetricEncryption.decrypt(
      AsymmetricEncryption.encrypt(text, keys.getPublic()), keys.getPrivate()));
  }

  @Test
  void roundTripsLongTextAndLargerKeys() throws Exception {
    KeyPair larger = rsa(3072);
    String text = "Unicode 🔐".repeat(10000);
    assertEquals(text, AsymmetricEncryption.decrypt(
      AsymmetricEncryption.encrypt(text, larger.getPublic()), larger.getPrivate()));
  }

  @Test
  void randomizesEachEncryption() throws Exception {
    assertNotEquals(AsymmetricEncryption.encrypt("same", keys.getPublic()),
      AsymmetricEncryption.encrypt("same", keys.getPublic()));
  }

  @Test
  void rejectsWrongKeyWithCommonFailure() throws Exception {
    String encrypted = AsymmetricEncryption.encrypt("private text", keys.getPublic());
    assertFailure(encrypted, rsa(2048));
  }

  @Test
  void rejectsTamperingInEveryEnvelopeRegion() throws Exception {
    byte[] envelope = envelope();
    for (int offset : new int[] {0, 4, 5, 9, 265, 277, envelope.length - 1}) {
      byte[] changed = envelope.clone();
      changed[offset] ^= 1;
      assertFailure(encode(changed), keys);
    }
  }

  @Test
  void rejectsEveryTruncationAndTrailingBytes() throws Exception {
    byte[] envelope = envelope();
    for (int length = 0; length < envelope.length; length++) {
      assertFailure(encode(Arrays.copyOf(envelope, length)), keys);
    }
    assertFailure(encode(Arrays.copyOf(envelope, envelope.length + 1)), keys);
  }

  @ParameterizedTest
  @ValueSource(ints = {-1, 0, 1, 255, 257, Integer.MAX_VALUE})
  void rejectsInvalidWrappedKeyLengths(int length) throws Exception {
    byte[] envelope = envelope();
    ByteBuffer.wrap(envelope).putInt(5, length);
    assertFailure(encode(envelope), keys);
  }

  @ParameterizedTest
  @ValueSource(strings = {"%bad", "a", "====", " \n"})
  void rejectsInvalidBase64(String text) {
    assertFailure(text, keys);
  }

  @Test
  void rejectsNulls() {
    assertThrows(NullPointerException.class, () -> AsymmetricEncryption.encrypt(null, keys.getPublic()));
    assertThrows(NullPointerException.class, () -> AsymmetricEncryption.encrypt("text", null));
    assertThrows(NullPointerException.class, () -> AsymmetricEncryption.decrypt(null, keys.getPrivate()));
    assertThrows(NullPointerException.class, () -> AsymmetricEncryption.decrypt("text", null));
  }

  @Test
  void rejectsNonRsaAndUndersizedKeys() throws Exception {
    KeyPairGenerator ec = KeyPairGenerator.getInstance("EC");
    ec.initialize(256);
    for (KeyPair invalid : new KeyPair[] {ec.generateKeyPair(), rsa(1024)}) {
      assertThrows(IllegalArgumentException.class,
        () -> AsymmetricEncryption.encrypt("text", invalid.getPublic()));
      assertThrows(IllegalArgumentException.class,
        () -> AsymmetricEncryption.decrypt("text", invalid.getPrivate()));
    }
  }

  private static void assertFailure(String encrypted, KeyPair pair) {
    GeneralSecurityException error = assertThrows(GeneralSecurityException.class,
      () -> AsymmetricEncryption.decrypt(encrypted, pair.getPrivate()));
    assertEquals("Decryption failed", error.getMessage());
    assertEquals(null, error.getCause());
  }

  private static byte[] envelope() throws Exception {
    return Base64.getDecoder().decode(AsymmetricEncryption.encrypt("secret", keys.getPublic()));
  }

  private static String encode(byte[] bytes) {
    return Base64.getEncoder().encodeToString(bytes);
  }

  private static KeyPair rsa(int bits) throws Exception {
    KeyPairGenerator generator = KeyPairGenerator.getInstance("RSA");
    generator.initialize(bits);
    return generator.generateKeyPair();
  }
}
