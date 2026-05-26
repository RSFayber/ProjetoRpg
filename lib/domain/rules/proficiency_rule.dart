List<String> mergeProficiencies(Iterable<List<String>> groups) {
  return {
    for (final group in groups)
      for (final item in group) item,
  }.toList()..sort();
}
