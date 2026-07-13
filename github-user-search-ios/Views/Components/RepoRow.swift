import SwiftUI

struct RepoRow: View {
    let repo: Repo

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(repo.name)
                .font(.headline)

            if let description = repo.description {
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 12) {
                if let language = repo.language {
                    Text(language)
                }
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                    Text("\(repo.stargazersCount)")
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 6)
    }
}

#Preview {
    RepoRow(repo: Repo(id: 1, name: "Hello-World", description: "My first repository", language: "Swift", stargazersCount: 80, htmlURL: "https://github.com/octocat/Hello-World"))
}
