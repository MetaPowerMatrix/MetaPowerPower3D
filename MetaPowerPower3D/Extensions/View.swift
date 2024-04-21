//
//  View.swift
//  MetaPowerGirl
//
//  Created by 石勇 on 2023/6/4.
//
import SwiftUI

public extension View {
    @ViewBuilder
    func errorAlert<E: LocalizedError, Content: View>(_ error: Binding<E?>, @ViewBuilder actions: @escaping (E, @escaping () -> Void) -> Content) -> some View {
        let wrappedValue = error.wrappedValue
        let title = wrappedValue?.errorDescription ?? ""
        if #available(iOS 15.0, *) {
            alert(title, isPresented: .constant(wrappedValue != nil), presenting: wrappedValue) { err in
                actions(err) {
                    error.wrappedValue = nil
                }
            } message: { error in
                if let suggestion = error.recoverySuggestion {
                    Text(suggestion)
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    func useToken(_ value: String) -> some View {
        environment(\.userToken, value)
    }
    func withSession(_ value: Session) -> some View {
        environment(\.userSession, value)
    }
    func withGame(_ value: PortalRoom) -> some View {
        environment(\.gameInfo, value)
    }
}
