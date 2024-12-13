/// Function to perform linear interpolation between two points.
/// Calculates the value of `y` for a given input `x`
/// based on the points (x0, y0) and (x1, y1).
///
/// Formula:
/// y = y0 + ((y1 - y0) * (x - x0) / (x1 - x0))
///
/// Example:
/// If (x0, y0) = (50, 150) and (x1, y1) = (100, 300),
/// then for x = 60, the resulting value of y is 180.
///
/// Parameters:
/// - [y0]: y-value at the starting point.
/// - [y1]: y-value at the ending point.
/// - [x]: the x-value for which we want to calculate the interpolated y.
/// - [x0]: x-value at the starting point.
/// - [x1]: x-value at the ending point.
///
/// Returns:
/// - The interpolated y-value corresponding to the input x.
double interpolateBetweenPoints({
  required double y0,
  required double y1,
  required double x,
  required double x0,
  required double x1,
}) {
  return y0 + ((y1 - y0) * (x - x0) / (x1 - x0));
}
