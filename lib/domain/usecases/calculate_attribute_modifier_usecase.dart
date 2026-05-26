import '../rules/attribute_modifier_rule.dart';

class CalculateAttributeModifierUseCase {
  const CalculateAttributeModifierUseCase();

  int call(int value) {
    return calculateAttributeModifier(value);
  }
}
