Overview:
  This project implements the Yet Another Global Scheme (YAGS) branch predictor integrated into a RISC-V RV32I pipelined processor. The goal is to enhance branch prediction accuracy while minimizing aliasing and unnecessary information in the Prediction History Table (PHT). This implementation achieves improved performance by dynamically managing biases and exceptions using sophisticated prediction techniques.

Features:
  Dynamic Branch Prediction: Adapts to runtime behavior for efficient branch handling.
  Integration with RISC-V: Embedded into the RV32I pipeline's fetch stage for reduced misprediction cycles.
  Direction Caches: Efficiently stores exceptional cases for enhanced accuracy.
  Two-Bit Saturating Counters: Provides reliable branch prediction with minimal errors.
  Global and Local Prediction: Combines global history with branch-specific behaviors.

Implementation Details:
  Processor: RV32I ISA with a 5-stage pipeline.
  Fetch Stage: Optimized to handle branch predictions and minimize wasted cycles.
  Choice Pattern History Table (PHT): Tracks bias and directs access to taken/not-taken caches.
  Global History Register (GHR): Maintains branch execution history.
  Taken and Not-Taken Caches: Uses XOR indexing for refined predictions with reduced aliasing.

Results:
  The YAGS predictor demonstrates significant performance improvements across various test cases:
  Nested loops: Near-optimal performance with over 99% accuracy.
  Mixed outcomes: Moderate improvement with 54% accuracy.
  Complex patterns: Exponential improvement with prediction accuracy exceeding 70% over repeated runs.
