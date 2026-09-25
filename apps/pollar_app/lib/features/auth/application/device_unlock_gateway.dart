abstract interface class DeviceUnlockGateway {
  Future<bool> isSupported();

  /// Delegates to the operating system. The app never handles a biometric or PIN.
  Future<bool> authenticate();
}
