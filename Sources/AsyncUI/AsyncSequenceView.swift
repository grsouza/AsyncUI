import AnyAsyncSequence
import SwiftUI

public struct AsyncSequenceView<
  Value,
  Content: View,
  ErrorContent: View
>: View {
  @State var result: Result<Value, Error>?
  let content: (Value) -> Content
  let errorContent: (Error) -> ErrorContent
  let value: AnyAsyncSequence<Value>
  
  public init(
    value: AnyAsyncSequence<Value>,
    @ViewBuilder content: @escaping (Value) -> Content,
    @ViewBuilder errorContent: @escaping (Error) -> ErrorContent
  ) {
    self.value = value
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
        for try await element in value {
          result = .success(element)
        }
      } catch {
        result = .failure(error)
      }
    }
  }
}

extension AsyncSequenceView where ErrorContent == Text {
  public init(
    value: AnyAsyncSequence<Value>,
    @ViewBuilder content: @escaping (Value) -> Content
  ) {
    self.init(
      value: value,
      content: content,
      errorContent: { error in Text(error.localizedDescription) }
    )
  }
}
