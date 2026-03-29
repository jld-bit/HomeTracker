import Foundation
import PDFKit
import UIKit

enum ExportType {
    case csv
    case pdf
    case backup
}

enum ExportService {
    static func export(items: [InventoryItem], type: ExportType) throws -> URL {
        switch type {
        case .csv:
            return try exportCSV(items: items)
        case .pdf:
            return try exportPDF(items: items)
        case .backup:
            return try exportBackup(items: items)
        }
    }

    private static func exportCSV(items: [InventoryItem]) throws -> URL {
        let header = "Name,Category,Estimated Value,Room,Notes,Created At\n"
        let rows = items.map {
            "\($0.name.escapedCSV),\($0.category.escapedCSV),\($0.estimatedValue),\($0.room.escapedCSV),\($0.notes.escapedCSV),\($0.createdAt.formatted())"
        }.joined(separator: "\n")

        let content = header + rows
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("HomeTracker-Export-\(UUID().uuidString).csv")

        try content.write(to: url, atomically: true, encoding: .utf8)
        return url
    }

    private static func exportPDF(items: [InventoryItem]) throws -> URL {
        let pageBounds = CGRect(x: 0, y: 0, width: 612, height: 792)
        let renderer = UIGraphicsPDFRenderer(bounds: pageBounds)
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("HomeTracker-Export-\(UUID().uuidString).pdf")

        try renderer.writePDF(to: url) { context in
            context.beginPage()

            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 22)
            ]
            let bodyAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12)
            ]

            var yOffset: CGFloat = 24
            NSString(string: "HomeTracker Inventory Export").draw(
                at: CGPoint(x: 20, y: yOffset),
                withAttributes: titleAttributes
            )
            yOffset += 36

            for (index, item) in items.enumerated() {
                let line = "\(index + 1). \(item.name) • \(item.category) • \(String(format: \"$%.2f\", item.estimatedValue)) • \(item.room)"
                NSString(string: line).draw(
                    at: CGPoint(x: 20, y: yOffset),
                    withAttributes: bodyAttributes
                )
                yOffset += 18

                if yOffset > 740 {
                    context.beginPage()
                    yOffset = 24
                }
            }
        }

        return url
    }

    private static func exportBackup(items: [InventoryItem]) throws -> URL {
        let payload = items.map { item in
            BackupItem(
                name: item.name,
                category: item.category,
                estimatedValue: item.estimatedValue,
                room: item.room,
                notes: item.notes,
                createdAt: item.createdAt
            )
        }

        let data = try JSONEncoder.encodedPretty(payload)
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("HomeTracker-Backup-\(UUID().uuidString).json")

        try data.write(to: url)
        return url
    }
}

private struct BackupItem: Codable {
    let name: String
    let category: String
    let estimatedValue: Double
    let room: String
    let notes: String
    let createdAt: Date
}

private extension JSONEncoder {
    static func encodedPretty<T: Encodable>(_ value: T) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(value)
    }
}

private extension String {
    var escapedCSV: String {
        let escaped = replacingOccurrences(of: "\"", with: "\"\"")
        return "\"\(escaped)\""
    }
}
