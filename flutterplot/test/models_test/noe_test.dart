import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math_64.dart';

void main() {


  test('test noe', () {

    double width = 1200;
    double height = 800;

    double xMin = 20;
    double xMax = 100;

    double yMin = 20;
    double yMax = 100;
   

    //Vector3 cameraPosition = Vector3(0, 0, 1);
    //Vector3 cameraFocusPosition = Vector3.zero();
    //Matrix4 view = makeViewMatrix(cameraPosition, cameraFocusPosition, Vector3(0, 1, 0));

    //Matrix4 perspective = makePerspectiveMatrix(pi/2, width/height, 0, 1);

    Matrix4 model = Matrix4.identity();

    model.translate(8.0, -1.0);

    Matrix4 projection = makeOrthographicMatrix(xMin, xMax, yMin, yMax, -1, 1);


    Matrix4 fromCanvas = Matrix4.compose(
        Vector3(-1.0, 1.0, 0.0),
        Quaternion.axisAngle(Vector3(1.0, 0.0, 0.0), pi),
        Vector3(2 / width, 2 / height, 1.0)
    );


    Matrix4 toCanvas = Matrix4.inverted(fromCanvas);


    Matrix4 transform = toCanvas * projection * model;

    var a = Vector3(100, 20, 0);


    var aClip = transform.transform3(a);

    print(aClip);


    expect(0, 0);

  });

}