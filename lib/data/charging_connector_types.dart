class ChargingConnectorTypes {
  static final _allConnectors = [
    ['IEC_62196_T1', 'assets/icons/connector_type_1_yazaki.svg', 'Type 1 (Yazaki)'],
    ['IEC_62196_T2', 'assets/icons/connector_type_2_mennekes.svg', 'Type 2 (Mennekes)'],
    ['IEC_62196_T3A', 'assets/icons/connector_type_3_le_grand.svg', 'Type 3 (Le Grand)'],
    ['CHADEMO', 'assets/icons/connector_type_chademo.svg', 'CHAdeMO'],
    ['DOMESTIC_F', 'assets/icons/connector_type_domestic.svg', 'Domestic'],
    ['IEC_62196_T2_COMBO', 'assets/icons/connector_type_combo.svg', 'Combo']
  ];

  static List<String> get connectorIds {
    return _allConnectors.map((e) => e[0]).toList();
  }

  static String svgAssetPathFor(String? connectorType) {
    for (final connector in _allConnectors) {
      if (connector[0] == connectorType) {
        return connector[1];
      }
    }

    return 'assets/icons/connector_type_2_mennekes.svg';
  }

  static String humanReadableNameFor(String connectorType) {
    for (final connector in _allConnectors) {
      if (connector[0] == connectorType) {
        return connector[2];
      }
    }

    return connectorType;
  }
}
