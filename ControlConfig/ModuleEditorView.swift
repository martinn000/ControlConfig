//
//  ContentView.swift
//  ControlConfig
//
//  Created by Hariz Shirazi on 2023-02-06.
//

import SwiftUI

struct CheckToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            Label {
                configuration.label
            } icon: {
                Image(systemName: configuration.isOn ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(configuration.isOn ? .green : .secondary)
                    .accessibility(label: Text(configuration.isOn ? "Checked" : "Unchecked"))
                    .imageScale(.large)
            }
        }
        .buttonStyle(.bordered).clipShape(Capsule()).foregroundColor(.white)
    }
}

struct CustomisationCard: View {
    @State var descString = ""
    @Binding var customisation: CCCustomisation

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                Image(systemName: "plus.magnifyingglass")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .aspectRatio(contentMode: .fit)

                Spacer().frame(width: 10)
                VStack(alignment: .leading) {
                    Text(customisation.module.description)
                        .font(.title3)
                        .foregroundColor(.primary)

                    Text(customisation.description)
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
                Spacer()

            }.padding([.horizontal, .top]).frame(maxWidth: .infinity)

            Spacer().frame(height: 10)
            HStack {
                Toggle("Enabled", isOn: $customisation.isEnabled).labelsHidden().toggleStyle(CheckToggleStyle())
                Spacer()
                Button(action: {}) { Label("Edit", systemImage: "pencil") }.buttonStyle(.bordered).clipShape(Capsule())
                Button(action: {}) { Label("Delete", systemImage: "trash").foregroundColor(.red) }.buttonStyle(.bordered).clipShape(Capsule())

            }.padding([.horizontal, .bottom]).frame(maxWidth: .infinity)
        }
        .background(.regularMaterial)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(.sRGB, red: 150/255, green: 150/255, blue: 150/255, opacity: 0.1), lineWidth: 1)
        )
        .padding([.top, .horizontal])
        .frame(maxWidth: .infinity)
    }
}

class CustomisationList: ObservableObject {
    @Published var list: [CCCustomisation]
    init(list: [CCCustomisation]) {
        self.list = list
    }

    init() {
        self.list = []
    }

    func addCustomisation(item: CCCustomisation) {
        self.list.append(item)
    }
}

struct SheetView: View {
    @Environment(\.dismiss) var dismiss
    @State var customisations: CustomisationList

    var body: some View {
        VStack(alignment: .leading) {
            Text("Add new module").font(.title)
            List {
                ForEach(getCCModules().filter { module in
                    if (customisations.list.contains { customisation in
                        customisation.module == module
                    }) { return false }
                    return true
                }) {
                    let module = $0
                    Button($0.description) {
                        customisations.addCustomisation(item: CCCustomisation(isEnabled: true, module: module))
                    }.buttonStyle(.plain)
                }
            }
        }
        Button("Press to dismiss") {
            dismiss()
        }
        .font(.title)
        .padding()
        .background(.black)
    }
}

struct ModuleEditorView: View {
//    @State var ccModule = CCModule(fileName: "NFCControlCenterModule.bundle")
//    @State var id = ""
    @State private var showingAddNewSheet = false
    @StateObject var customisations = CustomisationList()

    var body: some View {
        NavigationView {
            ScrollView(.vertical) {
                ForEach($customisations.list, id: \.module.bundleID) { item in
                    CustomisationCard(customisation: item)
                }
            }
            .frame(maxWidth: .infinity)
            .navigationTitle("ControlConfig")
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Button(action: {
//                        let success = overwriteModule(appBundleID: id, module: ccModule)
//                        if success {
//                            UIApplication.shared.alert(title: "Success", body: "Successfully wrote to file!", withButton: true)
//
//                            Haptic.shared.notify(.success)
//                        } else {
//                            UIApplication.shared.alert(title: "Error", body: "An error occurred while writing to the file.", withButton: true)
//
//                            Haptic.shared.notify(.error)
//                        }
                    }, label: {
                        Label("Apply", systemImage: "seal")
                        Text("Apply")

                    })

                    Button(action: {
                        respring()

                    }, label: {
                        Label("Respring", systemImage: "arrow.counterclockwise.circle")
                        Text("Respring")

                    })

                    Spacer()

                    Button(action: {
                        showingAddNewSheet.toggle()
                    }, label: {
                        Label("Add Module", systemImage: "plus.app")
                    }).sheet(isPresented: $showingAddNewSheet) {
                        SheetView(customisations: customisations)
                    }
                }
            }
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ModuleEditorView_Previews: PreviewProvider {
    static var previews: some View {
        ModuleEditorView()
    }
}
