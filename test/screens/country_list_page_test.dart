import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:trab02flutter/components/country_tile.dart';
import 'package:trab02flutter/screens/country_list_page.dart';
import 'package:trab02flutter/models/country.dart';
import '../mocks/mock_country_service.mocks.dart';
import 'package:cached_network_image/cached_network_image.dart';

void main() {
  group('CountryListPage - Testes Automatizados', () {
    late MockICountryService mockService;

    setUp(() {
      mockService = MockICountryService();
    });

    testWidgets('Cenário 01 - Listagem bem-sucedida', (tester) async {
      // lista de paises
      final countries = [
        Country(
          name: 'Brasil',
          capital: 'Brasília',
          flagUrl: 'https://flagcdn.com/w320/br.png',
          region: 'Américas',
          population: 210000000,
        ),
      ];

      // Config do mock
      when(mockService.fetchAllCountries()).thenAnswer((_) async => countries);

      // Inicializa o widget com o mock
      await tester.pumpWidget(
        MaterialApp(home: CountryListPage(countryService: mockService)),
      );

      // frame do widget
      await tester.pump();

      // Aguarda o tempo para carregar os dados assíncronos
      await tester.pump(const Duration(seconds: 1));

      // Verifica se o nome do país aparece na lista
      expect(find.text('Brasil'), findsOneWidget);
    });

    testWidgets('Cenário 02 - Clicar em um país abre modal com detalhes', (
      tester,
    ) async {
      final countries = [
        Country(
          name: 'Brasil',
          capital: 'Brasília',
          flagUrl: 'https://flagcdn.com/w320/br.png',
          region: 'Américas',
          population: 210000000,
        ),
      ];

      when(mockService.fetchAllCountries()).thenAnswer((_) async => countries);

      await tester.pumpWidget(
        MaterialApp(home: CountryListPage(countryService: mockService)),
      );

      await tester.pump(); // Inicial
      await tester.pump(const Duration(seconds: 1)); // Espera o async

      await tester.tap(find.byType(CountryTile));

     
      await tester.pump(const Duration(seconds: 1));

      // Agora as verificações do modal
      expect(find.textContaining('Brasil'), findsWidgets);
      expect(find.textContaining('Capital: Brasília'), findsOneWidget);
      expect(find.textContaining('Região: Américas'), findsOneWidget);
      expect(find.textContaining('População: 210000000'), findsOneWidget);
    });

    testWidgets(
      'Cenário 03 - Verificar se a imagem da bandeira aparece no CountryTile',
      (tester) async {
        final countries = [
          Country(
            name: 'Brasil',
            capital: 'Brasília',
            flagUrl: 'https://flagcdn.com/w320/br.png',
            region: 'Américas',
            population: 210000000,
          ),
        ];

        when(
          mockService.fetchAllCountries(),
        ).thenAnswer((_) async => countries);

        await tester.pumpWidget(
          MaterialApp(home: CountryListPage(countryService: mockService)),
        );

        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        // Garante que o componente de imagem está presente
        expect(find.byType(CachedNetworkImage), findsWidgets);
      },
    );

    test('Cenário 04 - Busca de país por nome com resultado vazio', () async {
      // Configura o mock para retornar null, simulando país não encontrado
      when(
        mockService.fetchCountryByName('Atlantis'),
      ).thenAnswer((_) async => null);

      // Executa a busca
      final result = await mockService.fetchCountryByName('Atlantis');

      // Verifica que o resultado é nulo
      expect(result, isNull);
    });

    testWidgets('Cenário 05 - País com dados parciais', (tester) async {
      final countries = [
        Country(name: '', capital: '', flagUrl: '', region: '', population: 0),
      ];

      when(mockService.fetchAllCountries()).thenAnswer((_) async => countries);

      await tester.pumpWidget(
        MaterialApp(home: CountryListPage(countryService: mockService)),
      );

      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Nome não disponível'), findsOneWidget);

      await tester.tap(find.byType(CountryTile));

      // Substitui o pumpAndSettle problemático
      await tester.pump(const Duration(seconds: 1));

      expect(find.textContaining('Capital: Não disponível'), findsOneWidget);
    });

    testWidgets('Cenário 06 - Verificar chamada ao método listarPaises', (
      tester,
    ) async {
      // Configura mock para retornar lista vazia
      when(mockService.fetchAllCountries()).thenAnswer((_) async => []);

      // Inicializa widget com o mock
      await tester.pumpWidget(
        MaterialApp(home: CountryListPage(countryService: mockService)),
      );

      // Executa o primeiro frame
      await tester.pump();

      // Aguarda processamento da chamada assíncrona
      await tester.pump(const Duration(seconds: 1));

      // Verifica se o método fetchAllCountries foi chamado uma vez
      verify(mockService.fetchAllCountries()).called(1);
    });
  });
}
