import SwiftUI
import ComposableArchitecture

struct AppState : Equatable {
    var childState : ChildState?
    var children : IdentifiedArrayOf<Child> = []
}

struct ChildState : Equatable {
    var input : String = ""
}

struct Child : Equatable, Identifiable {
    var id : UUID
    var name : String
}

enum AppActions {
    case setNavigation(active: Bool)
    case child(ChildActions)
    case row(id: UUID, action: ChildActions)
}

let appReducer = Reducer<AppState, AppActions, Void> { state, action, env in
    switch action {
    case .setNavigation(active: true):
        state.childState = ChildState()
    case .setNavigation(active: false):
        state.childState = nil
    case .child(.done):
        state.children.append(.init(id: UUID(), name: "any"))
        state.childState = nil
    case .row:
        break
    case .child(.noop):
        break
    }

    return .none
}.debug()

enum ChildActions {
    case done
    case noop
}

struct ChildStateView : View {
    let store : Store<ChildState, ChildActions>
    var body: some View {
        WithViewStore(store) { viewStore in
            Button(action: { viewStore.send(.done) }) {
                Text("Done!")
            }
        }
    }
}

struct ChildView : View {

    @Binding var child : Child

    var body: some View {
        Text("CHld")
    }
}

struct ContentView: View {
    let store : Store<AppState, AppActions>

    var body: some View {
        VStack {
            NavigationView {
                WithViewStore(store) { viewStore in
                    VStack { // WORKS
//                    List { Section { // DOESNT WORK
                            ForEachStore(store.scope(state: { $0.children },
                                                     action: AppActions.row(id:action:))) { rowStore in
                                WithViewStore(rowStore) { rowViewStore in
                                    NavigationLink(destination: ChildView(child: rowViewStore.binding(get: { $0 },
                                                                                                      send: .noop ) )) {
                                        Text("\(rowViewStore.id)")
                                    }
                                }
                            }
                            NavigationLink(
                                destination: IfLetStore(store.scope(state: { $0.childState },
                                                                    action: AppActions.child),
                                                        then: ChildStateView.init(store:)),
                                isActive: viewStore.binding(get: { $0.childState != nil },
                                                            send: AppActions.setNavigation(active:))) {
                                    Text("Navigate").padding()
                            }
                    } // END WORKS
//                        }} // END DOESNT WORK
                }
            }
        }
    }
}
