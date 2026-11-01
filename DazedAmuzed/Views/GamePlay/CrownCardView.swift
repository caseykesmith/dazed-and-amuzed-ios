//
//  CrownCardView.swift
//  DazedAmuzed
//
//  Shareable end-of-game stat card — save it or share it straight to a story.
//

import SwiftUI

struct CrownCardView: View {
    @ObservedObject var viewModel: GameViewModel
    @State private var shareImage: UIImage?
    @State private var showShareSheet = false
    @State private var showSavedToast = false

    var champion: Player? {
        viewModel.players.max { $0.score < $1.score }
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 18) {
                HStack {
                    Button {
                        viewModel.goTo(.results)
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Color(hex: "1A1A1A"))
                            .clipShape(Circle())
                    }
                    Spacer()
                    Text("YOUR CROWN CARD")
                        .font(AppTheme.interBold(12))
                        .tracking(2)
                        .foregroundColor(Color(hex: "A6A6A6"))
                    Spacer()
                    Color.clear.frame(width: 44, height: 44)
                }

                if let champion {
                    CrownCardFace(player: champion, viewModel: viewModel)
                        .frame(width: 316, height: 562)
                        .shadow(color: Color(hex: "FFD60A").opacity(0.18), radius: 30, y: 18)
                }

                Spacer()

                HStack(spacing: 10) {
                    Button(action: save) {
                        Text(showSavedToast ? "Saved!" : "Save")
                            .displayStyle(16)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 60)
                            .overlay(Capsule().stroke(Color.white, lineWidth: 2))
                    }

                    Button(action: share) {
                        HStack(spacing: 8) {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share to story")
                        }
                        .displayStyle(17)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, minHeight: 60)
                        .background(Color.white)
                        .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .sheet(isPresented: $showShareSheet) {
            if let shareImage {
                ActivitySheet(activityItems: [shareImage])
            }
        }
    }

    @MainActor
    private func renderedImage() -> UIImage? {
        guard let champion else { return nil }
        let renderer = ImageRenderer(content: CrownCardFace(player: champion, viewModel: viewModel).frame(width: 316, height: 562))
        renderer.scale = 3
        return renderer.uiImage
    }

    private func save() {
        guard let image = renderedImage() else { return }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        HapticsService.success()
        withAnimation { showSavedToast = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            withAnimation { showSavedToast = false }
        }
    }

    private func share() {
        guard let image = renderedImage() else { return }
        HapticsService.light()
        shareImage = image
        showShareSheet = true
    }
}

// MARK: - The card face (also used for the rendered share/save image)

private struct CrownCardFace: View {
    let player: Player
    @ObservedObject var viewModel: GameViewModel

    private var dateText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: Date()).uppercased()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("GAME NIGHT")
                    .font(AppTheme.interBold(11))
                    .tracking(1.5)
                Spacer()
                Text(dateText)
                    .font(AppTheme.interBold(11))
                    .tracking(1.5)
            }
            .foregroundColor(.black)

            Image(systemName: "crown.fill")
                .font(.system(size: 44))
                .foregroundColor(.black)
                .padding(.top, 28)

            Text(player.name)
                .displayStyle(72)
                .foregroundColor(.black)
                .lineLimit(1)
                .minimumScaleFactor(0.4)
                .padding(.top, 6)

            Text("CHAOS CHAMPION")
                .displayStyle(13)
                .tracking(0.5)
                .foregroundColor(Color(hex: "FFD60A"))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.black)
                .clipShape(Capsule())
                .padding(.top, 10)

            Spacer(minLength: 16)

            Rectangle()
                .fill(Color.black)
                .frame(height: 2)

            Grid(horizontalSpacing: 10) {
                GridRow(alignment: .top) {
                    statColumn("\(player.score)", "points")
                    statColumn("\(player.topCategory?.count ?? 0)", topCategoryLabel)
                    statColumn("\(viewModel.totalSkips)", "cards skipped")
                }
            }
            .padding(.top, 14)

            HStack {
                Text("DAZED & AMUZED")
                    .displayStyle(14)
                Spacer()
                Text("Play it on the App Store")
                    .font(AppTheme.interBold(10))
            }
            .foregroundColor(.black)
            .padding(.top, 12)
        }
        .padding(22)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color(hex: "FFD60A"))
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
    }

    private var topCategoryLabel: String {
        guard let top = player.topCategory, top.count > 0 else { return "rounds won" }
        return "\(top.category.displayName.lowercased()) wins"
    }

    private func statColumn(_ value: String, _ label: String) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(value)
                .displayStyle(24)
            Text(label)
                .font(AppTheme.interBold(9.5))
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .minimumScaleFactor(0.85)
        }
        .foregroundColor(.black)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Share sheet plumbing

private struct ActivitySheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    let vm = GameViewModel()
    vm.addPlayer(name: "Dani")
    vm.players[0].score = 10
    vm.players[0].categoryWins = [.debates: 4]
    return CrownCardView(viewModel: vm)
}
