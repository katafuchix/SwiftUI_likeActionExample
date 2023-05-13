//
//  ContentView.swift
//  SwiftUI_likeActionExample
//
//  Created by cano on 2023/05/13.
//

import SwiftUI
import Combine

struct ContentView: View {
    @ObservedObject private var viewModel = ViewModel()
    
    var searchButtonColor: Color {
        return viewModel.isSearchButtonEnabled ? Color.blue : Color.gray
    }
    
    var body: some View {
        
        VStack {
            ZStack {
                //Color.gray.opacity(0.6)
                HStack {
                    TextField("検索キーワード",text: $viewModel.searchWord)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding([.leading, .trailing], 8)
                        .frame(height: 32)
                        .background(Color.white.opacity(0.4))
                        .cornerRadius(8)
                    
                    Button(action: {
                        UIApplication.shared.endEditing() //キーボード下げ
                        viewModel.searchTriggerSubject.send(())
                    }) {
                        Text("Search")
                            .padding()
                            .frame(height: 36)
                            .foregroundColor(.white)
                            .background(self.searchButtonColor)  // ボタンの背景色を制御
                            .cornerRadius(10)
                    }
                }
                .padding([.leading, .trailing], 16)
            }
            .frame(height: 64)
            List(viewModel.result, id: \.idDrink) { cocktail in
                CocktailSearchRowView(cocktail: cocktail)
            }
            .overlay {
                if viewModel.isSearching {
                    ProgressView()
                }
            }
        }
        .alert(isPresented: $viewModel.showErrorAlert) {
            Alert(title: Text("エラー"), message: Text(viewModel.error?.localizedDescription ?? "エラー発生"), dismissButton: .default(Text("OK")))
        }
            
        /*
        NavigationView {
            
            TextField("Search", text: $viewModel.searchWord)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button(action: {
                //viewModel.buttonTapped()
            }) {
                Text("Search")
                    .padding()
                    .foregroundColor(.white)
                    .background(self.searchButtonColor)  // ボタンの背景色を制御
                    .cornerRadius(10)
            }
            
            List(viewModel.result, id: \.idDrink) { cocktail in
                CocktailSearchRowView(cocktail: cocktail)
            }
            .overlay {
                if viewModel.isSearching {
                    ProgressView()
                }
            }
        }
        .navigationTitle("Search Cacktail Combine")
                    .navigationBarTitleDisplayMode(.inline)
                    .searchable(text: $viewModel.searchWord)
                    .alert(isPresented: $viewModel.showErrorAlert) {
                        Alert(title: Text("エラー"), message: Text(viewModel.error?.localizedDescription ?? "エラー発生"), dismissButton: .default(Text("OK")))
                    }
        */
        /*
        VStack {
            TextField("Search", text: $viewModel.searchWord)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button(action: {
                //viewModel.buttonTapped()
            }) {
                Text("Search")
                    .padding()
                    .foregroundColor(.white)
                    .background(self.searchButtonColor)  // ボタンの背景色を制御
                    .cornerRadius(10)
            }
            .disabled(!viewModel.isSearchButtonEnabled)  // isButtonEnabledプロパティに基づいてボタンの有効/無効を制御
        }
        .padding()
        .alert(isPresented: $viewModel.showErrorAlert) {
            Alert(title: Text("エラー"), message: Text(viewModel.error?.localizedDescription ?? "エラー発生"), dismissButton: .default(Text("OK")))
        }
         */
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
