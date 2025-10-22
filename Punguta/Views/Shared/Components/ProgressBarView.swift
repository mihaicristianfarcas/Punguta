//
//  ProgressBarView.swift
//  Punguta
//
//  Created by Mihai-Cristian Farcas on 21.10.2025.
//

import SwiftUI

/// Reusable progress bar component
/// Shows completion progress with smooth animations
struct ProgressBarView: View {
    
    // MARK: - Properties
    
    let progress: Double // 0.0 to 1.0
    var height: CGFloat = 8
    var backgroundColor: Color = Color(.systemGray5)
    var foregroundColor: Color = AppTheme.Colors.success
    
    // MARK: - Body
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(backgroundColor)
                    .frame(height: height)
                
                // Foreground progress
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(foregroundColor)
                    .frame(
                        width: max(0, min(geometry.size.width * progress, geometry.size.width)),
                        height: height
                    )
                    .animation(.easeInOut(duration: AppTheme.Animation.standard), value: progress)
            }
        }
        .frame(height: height)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: AppTheme.Spacing.lg) {
        ProgressBarView(progress: 0.0)
        ProgressBarView(progress: 0.25)
        ProgressBarView(progress: 0.5)
        ProgressBarView(progress: 0.75)
        ProgressBarView(progress: 1.0)
    }
    .padding()
}
