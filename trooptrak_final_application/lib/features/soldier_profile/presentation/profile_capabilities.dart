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
}
