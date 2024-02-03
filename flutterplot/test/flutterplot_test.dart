

class Test {

  Test(this.a);
  double a;

  @override
  bool operator ==(covariant Test other) {
    return other.a == a;
  }

  @override
  int get hashCode => a.hashCode;
  
}


void main() {

  var a = Test(1.0);
  var b;

  b.a = 3.0;

  print(a.a);
  
    
}


