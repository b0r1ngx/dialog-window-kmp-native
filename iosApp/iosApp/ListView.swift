import SwiftUI
import KMMViewModelSwiftUI
import Shared

struct ListView: View {
    let viewModel = ListViewModel(
        museumRepository: KoinDependencies().museumRepository
    )
    
    @State
    var objects: [MuseumObject] = []
    
    let columns = [
        GridItem(.adaptive(minimum: 120), alignment: .top)
    ]
    
    // TODO: Add pagination to viewModel, and then here!
    var body: some View {
        ZStack {
            if !objects.isEmpty {
                NavigationStack {
                    ScrollView {
                        LazyVGrid(columns: columns, alignment: .leading, spacing: 20) {
                            ForEach(objects, id: \.objectID) { item in
                                NavigationLink(destination: DetailView(objectId: item.objectID)) {
                                    ObjectFrame(obj: item, onClick: {})
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            } else {
                // Current behaviour: when user start the app, he anyway seeing No data available
                // TODO: Change behaviour! Not show Text("No.."), at start of awaiting the task run (when we not get any info from viewModel (do we need check user allowness of connection to internet, to fast say that you have no internet or msth like this, )
                // (this app is just an template to start from. I want to research how it can be realised
                //  and used to have a good behaviour for user)
                Text("No data available")
            }
        }.task {
            for await objs in viewModel.objects {
                objects = objs
            }
        }
    }
}

private struct ObjectFrame: View {
    let obj: MuseumObject
    let onClick: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            GeometryReader { geometry in
                AsyncImage(url: URL(string: obj.primaryImageSmall)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: geometry.size.width, height: geometry.size.width)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: geometry.size.width, height: geometry.size.width)
                            .clipped()
                            .aspectRatio(1, contentMode: .fill)
                    default:
                        EmptyView()
                            .frame(width: geometry.size.width, height: geometry.size.width)
                    }
                }
            }
            .aspectRatio(1, contentMode: .fit)
            
            Text(obj.title)
                .font(.headline)
            
            Text(obj.artistDisplayName)
                .font(.subheadline)
            
            Text(obj.objectDate)
                .font(.caption)
        }
    }
}
