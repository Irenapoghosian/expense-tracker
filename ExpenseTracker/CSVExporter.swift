import Foundation

enum CSVExporter {

    /// Builds CSV text for the given transactions.
    static func makeCSV(from transactions: [TransactionEntity]) -> String {
        var lines = ["Date,Title,Category,Amount"]

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        for transaction in transactions {
            let date = transaction.date.map { dateFormatter.string(from: $0) } ?? ""
            let title = escape(transaction.title ?? "")
            let category = escape(Category.from(transaction.category).displayName)
            let amount = String(format: "%.2f", transaction.amount)
            lines.append("\(date),\(title),\(category),\(amount)")
        }

        return lines.joined(separator: "\n")
    }

    /// Writes the CSV to a temporary file and returns its URL, ready to share.
    static func exportToTemporaryFile(transactions: [TransactionEntity]) -> URL? {
        let csvString = makeCSV(from: transactions)
        let fileName = "ExpenseTracker-Export-\(Int(Date().timeIntervalSince1970)).csv"
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        do {
            try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            return nil
        }
    }

    /// Escapes a field for safe CSV output (wraps in quotes if it contains a comma, quote, or newline).
    private static func escape(_ field: String) -> String {
        guard field.contains(",") || field.contains("\"") || field.contains("\n") else {
            return field
        }
        let escaped = field.replacingOccurrences(of: "\"", with: "\"\"")
        return "\"\(escaped)\""
    }
}
