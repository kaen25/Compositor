import Foundation
import Testing
@testable import Compositor

/// Rustoshop fixtures: opens every `.comp` in `fixtures/` the way the app does (`ProjectStore.load`) and exports it
/// with `ImageExporter`, into `fixtures-out/<name>.png`. A project the app refuses gets `fixtures-out/<name>.error.txt`
/// instead, with the reason. Runs only where `fixtures/` exists (the `fixtures` branch of the Rustoshop fork).
@MainActor
struct FixtureExportTests {
    @Test func exportFixtures() async throws {
        let root = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
        let input = root.appending(path: "fixtures"), output = root.appending(path: "fixtures-out")
        let files = FileManager.default
        guard let names = try? files.contentsOfDirectory(atPath: input.path) else { return }
        try files.createDirectory(at: output, withIntermediateDirectories: true)
        for name in names.sorted() where name.hasSuffix(".comp") {
            let base = String(name.dropLast(".comp".count))
            do {
                let snapshot = try await ProjectStore.shared.load(from: input.appending(path: name))
                try await ImageExporter.shared.exportPNG(snapshot, to: output.appending(path: "\(base).png"))
            } catch {
                try "\(error)\n\(error.localizedDescription)\n".write(to: output.appending(path: "\(base).error.txt"),
                                                                       atomically: true, encoding: .utf8)
            }
        }
    }
}
