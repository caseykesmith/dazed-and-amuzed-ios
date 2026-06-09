//
//  ExtensionPacksView.swift
//  DazedAmuzed
//
//  Created by PJ on 4/14/26.
//


import SwiftUI
import StoreKit

struct ExtensionPacksView: View {
    @ObservedObject var viewModel: GameViewModel
    @StateObject private var store = StoreKitService.shared
    @Environment(\.dismiss) private var dismiss
    @State private var isPurchasing = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(AppTheme.textMuted)
                                .frame(width: 36, height: 36)
                                .background(AppTheme.card)
                                .cornerRadius(18)
                        }
                        Spacer()
                        
                        Button {
                            Task {
                                await store.restorePurchases()
                            }
                        } label: {
                            Text("Restore")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(AppTheme.textMuted)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    
                    // Title
                    VStack(spacing: 8) {
                        Text("🎉")
                            .font(.system(size: 48))
                        
                        Text("Extension Packs")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(AppTheme.text)
                        
                        Text("More questions, more fun")
                            .font(.system(size: 16, design: .rounded))
                            .foregroundColor(AppTheme.textMuted)
                    }
                    .padding(.bottom, 8)
                    
                    // Premium Unlock Card
                    PremiumUnlockCard(store: store, isPurchasing: $isPurchasing)
                        .padding(.horizontal, 24)
                    
                    // Individual Packs
                    VStack(spacing: 12) {
                        Text("OR BUY INDIVIDUALLY")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .tracking(2)
                            .foregroundColor(AppTheme.textDim)
                        
                        ForEach(ExtensionPack.allPacks) { pack in
                            ExtensionPackCard(pack: pack, store: store, isPurchasing: $isPurchasing)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
            
            if isPurchasing {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
            }
        }
        .alert("Purchase Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
}

// MARK: - Premium Unlock Card

struct PremiumUnlockCard: View {
    @ObservedObject var store: StoreKitService
    @Binding var isPurchasing: Bool
    
    var premiumProduct: Product? {
        store.products.first { $0.id == StoreKitService.premiumUnlock }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("👑")
                    .font(.system(size: 32))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Premium Unlock")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.text)
                    
                    Text("All packs + future updates")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(AppTheme.textMuted)
                }
                
                Spacer()
            }
            
            // Features list
            VStack(alignment: .leading, spacing: 8) {
                FeatureRow(text: "All 6 card types unlocked")
                FeatureRow(text: "All 6 extension packs included")
                FeatureRow(text: "Future packs free forever")
                FeatureRow(text: "700+ total questions")
            }
            
            if store.hasPremium {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Purchased")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.green)
                } 
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.green.opacity(0.15))
                .cornerRadius(12)
            } else {
                Button {
                    Task {
                        await purchasePremium()
                    }
                } label: {
                    HStack {
                        Text("Unlock Everything")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                        
                        Text("•")
                        
                        Text(premiumProduct?.displayPrice ?? "$4.99")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(AppTheme.primaryGradient)
                    .cornerRadius(12)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppTheme.card)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [Color(hex: "FFD700"), Color(hex: "FFA500")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
        )
    }
    
    private func purchasePremium() async {
        guard let product = premiumProduct else { return }
        isPurchasing = true
        do {
            _ = try await store.purchase(product)
            HapticsService.success()
        } catch {
            print("Purchase failed: \(error)")
        }
        isPurchasing = false
    }
}

// MARK: - Feature Row

struct FeatureRow: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(AppTheme.purple)
            
            Text(text)
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(AppTheme.textMuted)
        }
    }
}

// MARK: - Pack Card

struct ExtensionPackCard: View {
    let pack: ExtensionPack
    @ObservedObject var store: StoreKitService
    @Binding var isPurchasing: Bool
    
    var product: Product? {
        store.products.first { $0.id == pack.productID }
    }
    
    var isOwned: Bool {
        store.hasAccess(to: pack.productID)
    }
    
    var body: some View {
        HStack(spacing: 14) {
            Text(pack.emoji)
                .font(.system(size: 28))
                .frame(width: 50, height: 50)
                .background(pack.color.opacity(0.2))
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(pack.name)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(AppTheme.text)
                
                Text("\(pack.questionCount) questions")
                    .font(.system(size: 13, design: .rounded))
                    .foregroundColor(AppTheme.textMuted)
            }
            
            Spacer()

            if pack.isComingSoon {
                Text("Coming Soon")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(AppTheme.textMuted)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(AppTheme.card)
                    .overlay(
                        Capsule().stroke(AppTheme.border, lineWidth: 1)
                    )
                    .clipShape(Capsule())
            } else if isOwned {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.green)
            } else {
                Button {
                    Task {
                        await purchasePack()
                    }
                } label: {
                    Text(product?.displayPrice ?? "$0.99")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(pack.color)
                        .cornerRadius(20)
                }
            }
        }
        .padding(16)
        .opacity(pack.isComingSoon ? 0.6 : 1)
        .background(AppTheme.card)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(AppTheme.border, lineWidth: 1)
        )
    }
    
    private func purchasePack() async {
        guard let product = product else { return }
        isPurchasing = true
        do {
            _ = try await store.purchase(product)
            HapticsService.success()
        } catch {
            print("Purchase failed: \(error)")
        }
        isPurchasing = false
    }
}

#Preview {
    ExtensionPacksView(viewModel: GameViewModel())
}
