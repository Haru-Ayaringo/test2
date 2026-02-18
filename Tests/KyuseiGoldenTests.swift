#if canImport(XCTest) && canImport(KyuseiApp)
import XCTest
@testable import KyuseiApp

final class KyuseiGoldenTests: XCTestCase {
    private struct GoldenCase: Codable {
        struct ExpectedCell: Codable {
            let position: BoardPosition
            let starNumber: Int
            let markerRawValues: [String]
        }

        let birthDate: Date
        let date: Date
        let type: BoardType
        let expectedCells: [ExpectedCell]
    }

    func test_stubEngine_matchesGoldenCases() throws {
        let cases = try loadCases()

        guard !cases.isEmpty else {
            // TODO: 既存アプリの正解盤を投入したら、このskipを外して回帰検知を有効化する。
            throw XCTSkip("golden_cases.json is empty")
        }

        let engine: KyuseiEngine = StubKyuseiEngine()

        for testCase in cases {
            let profile = Profile(name: "Golden", birthDate: testCase.birthDate)
            let board = engine.makeBoard(profile: profile, date: testCase.date, type: testCase.type)

            let actual = board.cells.map {
                GoldenCase.ExpectedCell(
                    position: $0.position,
                    starNumber: $0.starNumber,
                    markerRawValues: $0.markers.map(\.rawValue).sorted()
                )
            }
            .sorted { $0.position.rawValue < $1.position.rawValue }

            let expected = testCase.expectedCells
                .map {
                    GoldenCase.ExpectedCell(
                        position: $0.position,
                        starNumber: $0.starNumber,
                        markerRawValues: $0.markerRawValues.sorted()
                    )
                }
                .sorted { $0.position.rawValue < $1.position.rawValue }

            XCTAssertEqual(actual.count, expected.count)
            zip(actual, expected).forEach { a, e in
                XCTAssertEqual(a.position, e.position)
                XCTAssertEqual(a.starNumber, e.starNumber)
                XCTAssertEqual(a.markerRawValues, e.markerRawValues)
            }
        }
    }

    private func loadCases() throws -> [GoldenCase] {
        let url = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .appendingPathComponent("Resources/Golden/golden_cases.json")

        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode([GoldenCase].self, from: data)
    }
}
#endif
