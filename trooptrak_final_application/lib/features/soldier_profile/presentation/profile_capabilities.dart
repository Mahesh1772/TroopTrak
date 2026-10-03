/// What a viewer may do on a soldier profile; one page serves every role.
class ProfileCapabilities {
  const ProfileCapabilities({
    this.canEdit = false,
    this.canDelete = false,
    this.canManageStatuses = false,
    this.canManageAttendance = false,
    this.showQr = false,
    this.showSignOut = false,
    this.showThemeToggle = false,
  });

  final bool canEdit;
  final bool canDelete;
  final bool canManageStatuses;
  final bool canManageAttendance;
  final bool showQr;
  final bool showSignOut;
  final bool showThemeToggle;

  static const commanderViewingSoldier = ProfileCapabilities(
    canEdit: true,
    canDelete: true,
    canManageStatuses: true,
    canManageAttendance: true,
  );

  /// Source own-profile tabs kept full status and attendance management.
  static const commanderSelf = ProfileCapabilities(
    canEdit: true,
    canDelete: true,
    canManageStatuses: true,
    canManageAttendance: true,
    showSignOut: true,
    showThemeToggle: true,
  );

  /// Source soldier profile: read-only tabs, own edit, QR and sign out; no
  /// delete (the source never wired its delete code to a button).
  static const soldierSelf = ProfileCapabilities(
    canEdit: true,
    showQr: true,
    showSignOut: true,
  );
}
