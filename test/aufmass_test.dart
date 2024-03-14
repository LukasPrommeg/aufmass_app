// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:aufmass_app/PlanPage/2D_Objects/flaeche.dart';
import 'package:aufmass_app/PlanPage/2D_Objects/grundflaeche.dart';
import 'package:aufmass_app/PlanPage/2D_Objects/linie.dart';
import 'package:aufmass_app/PlanPage/2D_Objects/punkt.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("Tests der Aufmaßapp", () {
    group("Linienende", () {
      test("0° 1m", () {
        Linie linie = Linie.fromStart(angle: 0, length: 1000, start: Punkt.fromPoint(point: Offset.zero));
        expect(linie.end.getRounded(), const Offset(0, -1000));
      });
      test("45° 1m", () {
        Linie linie = Linie.fromStart(angle: 45, length: 1000, start: Punkt.fromPoint(point: Offset.zero));
        expect(linie.end.getRounded(), const Offset(707.11, -707.11));
      });
      test("225° 1m", () {
        Linie linie = Linie.fromStart(angle: 225, length: 1000, start: Punkt.fromPoint(point: Offset.zero));
        expect(linie.end.getRounded(), const Offset(-707.11, 707.11));
      });
    });
    group("Flächenberechnunug", () {
      test("Quadrat 1000x1000", () {
        Flaeche flaeche = Flaeche(
          walls: [
            Linie.fromStart(angle: 0, length: 1000, start: Punkt.fromPoint(point: Offset.zero)),
            Linie.fromStart(angle: 90, length: 1000, start: Punkt.fromPoint(point: const Offset(0, -1000))),
            Linie.fromStart(angle: 180, length: 1000, start: Punkt.fromPoint(point: const Offset(1000, -1000))),
          ],
        );

        expect(flaeche.area, 1000000);
      });
      test("Dreieck", () {
        Flaeche flaeche = Flaeche(
          walls: [
            Linie.fromStart(angle: 0, length: 1000, start: Punkt.fromPoint(point: Offset.zero)),
            Linie.fromStart(angle: 90, length: 1000, start: Punkt.fromPoint(point: const Offset(0, -1000))),
          ],
        );

        expect(flaeche.area, 500000);
      });
      test("Komplexe Fläche", () {
        Flaeche flaeche = Flaeche(
          walls: [
            Linie.fromStart(angle: 0, length: 1000, start: Punkt.fromPoint(point: Offset.zero)),
            Linie.fromStart(angle: 90, length: 1000, start: Punkt.fromPoint(point: const Offset(0, -1000))),
            Linie.fromStart(angle: 180, length: 250, start: Punkt.fromPoint(point: const Offset(1000, -1000))),
            Linie.fromStart(angle: 90, length: 500, start: Punkt.fromPoint(point: const Offset(1000, -750))),
            Linie.fromStart(angle: 180, length: 500, start: Punkt.fromPoint(point: const Offset(1500, -750))),
          ],
        );

        expect(flaeche.area, 1187500);
      });
    });
    group("Max. mögliche Länge", () {
      Grundflaeche grundflaeche = Grundflaeche(
        raumName: "Test",
        walls: [
          Linie.fromStart(angle: 0, length: 1000, start: Punkt.fromPoint(point: Offset.zero)),
          Linie.fromStart(angle: 90, length: 1000, start: Punkt.fromPoint(point: const Offset(0, -1000))),
          Linie.fromStart(angle: 180, length: 1000, start: Punkt.fromPoint(point: const Offset(1000, -1000))),
        ],
      );

      test("Bottom-Left 45°", () async {
        double length = await grundflaeche.findMaxLength(Punkt.fromPoint(point: Offset.zero), 45);
        expect(length, 1414.21);
      });

      test("Bottom-Middle 0°", () async {
        double length = await grundflaeche.findMaxLength(Punkt.fromPoint(point: const Offset(500, 0)), 0);
        expect(length, 1000);
      });

      test("(0|-600) 146.31°", () async {
        double length = await grundflaeche.findMaxLength(Punkt.fromPoint(point: const Offset(0, -600)), 146.31);
        expect(length, 721.11);
      });
    });
  });
}
