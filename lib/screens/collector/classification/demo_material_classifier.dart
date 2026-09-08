import 'dart:io';

class ClassificationResult {
  final String materialId;
  final String materialName;
  final double confidence;

  const ClassificationResult({
    required this.materialId,
    required this.materialName,
    required this.confidence,
  });
}

/// Prototype-only classifier.
///
/// This deliberately does not pretend to be a trained production ML model.
/// It gives a deterministic demo result and the collector can always correct it.
///
/// Replace this class later with a TFLite implementation without changing the
/// classification screen's interface.
class DemoMaterialClassifier {
  Future<ClassificationResult> classify(File image) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));

    return const ClassificationResult(
      materialId: 'pcb',
      materialName: 'PCB',
      confidence: 0.91,
    );
  }
}
