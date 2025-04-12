import SwiftUI

struct Tile: View {
  var word: String
  var selected: Bool
  var selectAction: () -> Void
  
  var borderWidth: CGFloat {
    return selected ? 4 : 0
  }
  
  var body: some View {
    Text(word)
      .multilineTextAlignment(.center)
      .lineLimit(1)
      .minimumScaleFactor(0.1)
      .padding(8)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .aspectRatio(1, contentMode: .fit)
      .bold()
      .background(
        RoundedRectangle(
          cornerSize: CGSize(width: 10, height: 10)
        )
        .fill(Color.secondaryBackground)
        .addBorder(Color.accentColor, width: borderWidth, cornerRadius: 10)
      ).onTapGesture(perform: selectAction)
  }
}