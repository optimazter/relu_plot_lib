

class Crosshair {
  
  Crosshair(
    {required this.label, 
    required this.active, 
    required this.yPadding,
    this.width = 80,
    this.height = 40,});

  final String label;
  final bool active;
  final double yPadding;
  final double width;
  final double height;

  double x = 0;
  int prevIndex = 0;

  

  @override
  bool operator ==(Object other) =>
      other is Crosshair &&
      other.runtimeType == runtimeType &&
      other.x == x &&
      other.label == label;



  @override
  int get hashCode => label.hashCode * x.hashCode;

  

  
}