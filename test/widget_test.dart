import 'package:flutter_test/flutter_test.dart';
import 'package:tiket_bioskop/providers/film_provider.dart';

void main() {
  test('FilmProvider initial state test', () {
    final provider = FilmProvider();
    expect(provider.films.isNotEmpty, true);
  });
}
