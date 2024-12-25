class FilterParticipantsUseCase {
  final Map<String, List<String>> conductTypeRestrictions = {
    'run': ['Ex RMJ', 'Ex Lower Limb', 'LD'],
    'route march': [
      'Ex RMJ', 'Ex Heavy Loads', 'Ex Lower Limbs', 'LD',
      'Ex Uniform', 'Ex Boots', 'Ex FLEGs',
    ],
    'ippt': [
      'Ex Upper Limb', 'LD', 'Ex Lower Limb', 'Ex RMJ',
      'Ex Pushup', 'Ex Situp'
    ],
    'outfield': [
      'Ex Sunlight', 'Ex grass', 'Ex Outfield',
      'Ex Uniform', 'Ex Boots'
    ],
    'metabolic circuit': [
      'Ex RMJ', 'Ex Lower Limb', 'LD',
    ],
    'combat circuit': [
      'Ex Uniform', 'Ex Boots', 'Ex RMJ', 'Ex Heavy Loads',
      'Ex Lower Limb', 'Ex FLEGs', 'LD',
    ],
    'live firing': [
      'Ex FLEGs', 'Ex Uniform', 'Ex Boots', 'LD',
      'Ex Lower Limb', 'Ex RMJ'
    ],
    'soc/voc': [
      'Ex Upper Limb', 'LD', 'Ex Lower Limb', 'Ex RMJ',
      'Ex Uniform', 'Ex Boots', 'Ex FLEGs'
    ],
  };

  Future<Map<String, String>> execute(
    String conductType,
    List<Map<String, dynamic>> statusList,
  ) async {
    Map<String, String> soldierReason = {};
    
    print('Filtering participants for conduct type: $conductType');
    print('Received status list: $statusList');
    
    final normalizedConductType = conductType.toLowerCase();
    
    if (!conductTypeRestrictions.containsKey(normalizedConductType)) {
      print('Warning: Unknown conduct type: $conductType (normalized: $normalizedConductType)');
      print('Available conduct types: ${conductTypeRestrictions.keys.toList()}');
      return soldierReason;
    }

    print('Restrictions for this conduct type: ${conductTypeRestrictions[normalizedConductType]}');

    for (var status in statusList) {
      print('Processing status: $status');
      try {
        if (status['statusType'] == 'Leave') {
          soldierReason[status['Name']] = status['statusName'];
          print('Soldier ${status['Name']} removed due to Leave: ${status['statusName']}');
        } else if (status['statusType'] == 'Excuse') {
          print('Checking excuse ${status['statusName']} against restrictions: ${conductTypeRestrictions[normalizedConductType]}');
          if (conductTypeRestrictions[normalizedConductType]!.contains(status['statusName'])) {
            soldierReason[status['Name']] = status['statusName'];
            print('Soldier ${status['Name']} removed due to Excuse: ${status['statusName']}');
          }
        }
      } catch (e) {
        print('Error processing status for soldier: ${status['Name']}, Error: $e');
        continue;
      }
    }

    print('Total soldiers removed: ${soldierReason.length}');
    print('Removal reasons: $soldierReason');
    
    return soldierReason;
  }
} 