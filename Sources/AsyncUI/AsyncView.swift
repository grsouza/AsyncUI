import SwiftUI

public struct AsyncView<Value, Content: View>: View {
  @State var result: Value?
  let action: () async -> Value
  let content: (Value) -> Content
  
  public init(
    action: @escaping () async -> Value,
    @ViewBuilder content: @escaping (Value) -> Content
  ) {
    self.action = action
    self.content = content
  }
  
  public var body: some View {
    Group {
      if let result = result {
        content(result)
      } else {
        ProgressView()
      }
    }
    .task {
      result = await action()
    }
  }
}
