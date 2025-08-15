enum ParticipantType {
  active('active'),
  passive('passive'),
  former('former');

  const ParticipantType(this.label);
  final String label;

  static final Map<String, ParticipantType> _labelMap = {
    for (ParticipantType participantType in ParticipantType.values) participantType.label: participantType
  };

  static ParticipantType? fromLabel(String? label) => (label==null) ? null : _labelMap[label];

  @override
  String toString() => label;
}