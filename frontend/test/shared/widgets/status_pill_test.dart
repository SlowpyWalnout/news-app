import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/shared/widgets/status_pill.dart';

import '../../helpers/helpers.dart';

// Regression: la etiqueta en inglés "ALREADY READ" es más larga que la
// española "YA LO LEÍ" y no cabía en el ancho de la card en "Leer después"
// — el Row interno (icono + texto) no tenía forma de encoger, así que
// desbordaba a la derecha (banner rojo/amarillo de overflow de Flutter).
void main() {
  testWidgets('a long label does not overflow a narrow width', (tester) async {
    await tester.pumpApp(
      SizedBox(
        width: 140,
        child: StatusPill(
          label: 'ALREADY READ',
          variant: ArticlePillVariant.alreadyRead,
          icon: null,
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
