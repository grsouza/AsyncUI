import SwiftUI

public struct AsyncThrowingView<
  Value,
  Content: View,
  ErrorContent: View
>: View {
  @State var result: Result<Value, Error>?
  let action: () async throws -> Value
  let content: (Value) -> Content
  let errorContent: (Error) -> ErrorContent
  
  public init(
    action: @escaping () async throws -> Value,
    @ViewBuilder content: @escaping (Value) -> Content,
    @ViewBuilder errorContent: @escaping (Error) -> ErrorContent
  ) {
    self.action = action
    self.content = content
    self.errorContent = errorContent
  }
  
  public var body: some View {
    Group {
      switch result {
      case .success(let value):
        content(value)
      case .failure(let error):
        errorContent(error)
      case .none:
        ProgressView()
      }
    }
    .task {
      do {
        result = .success(try await action())
      } catch {
        result = .failure(error)
      }
    }
  }
}

extension AsyncThrowingView where ErrorContent == Text {
  public init(
    action: @escaping () async throws -> Value,
    @ViewBuilder content: @escaping (Value) -> Content
  ) {
    self.init(
      action: action,
      content: content,
      errorContent: { Text($0.localizedDescription) }
    )
  }
}

