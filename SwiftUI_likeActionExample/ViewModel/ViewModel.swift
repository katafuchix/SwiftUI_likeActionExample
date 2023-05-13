//
//  ViewModel.swift
//  SwiftUI_likeActionExample
//
//  Created by cano on 2023/05/13.
//

import Foundation
import Combine

class ViewModel: ObservableObject {
    
    // MARK: - Input
    // 検索キーワード
    @Published var searchWord: String = ""
    // 検索トリガ
    @Published var searchTriggerSubject = PassthroughSubject<Void, Never>()
    
    // MARK: - Output
    // 検索結果
    @Published private(set) var result: [Cocktail] = []
    // 検索中か?
    @Published var isSearching = false
    // エラー
    @Published var showErrorAlert = false
    @Published var error: Error?
    // 検索可能か？ 計算型プロパティなので @Published は不要
    var isSearchButtonEnabled: Bool {
        return searchWord.count >= 3
    }
    
    // MARK: - Private
    // searchWordの値を受ける
    private let searchSubject = PassthroughSubject<String, Never>()
    
    // searchSubjectに値がくると処理が走る
    private var searchPublisher: AnyPublisher<String, Never> {
        return searchSubject.eraseToAnyPublisher()
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // 検索トリガ起動
        searchTriggerSubject
            .sink { [weak self] _ in
                guard let searchText = self?.searchWord else { return }
                self?.searchSubject.send(searchText)
            }
            .store(in: &cancellables)
        
        // searchSubjectから呼ばれる検索処理
        searchPublisher
            .flatMap { searchText -> AnyPublisher<[Cocktail], Error>  in
                self.isSearching = true
                // ネットワークリクエストなどの非同期処理を行うPublisherを返す
                return self.searchAction(query: searchText)
            }
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    // 成功時の処理
                    print("finished")
                    break
                case .failure(let error):
                    // エラー時の処理
                    print("Search failed with error: \(error)")
                    self.isSearching = false
                    self.showErrorAlert = true
                    self.error = error
                }
            }, receiveValue: { response in
                // 成功時の処理
                self.isSearching = false
                self.result = response
                print("Received search response: \(response)")
            })
            .store(in: &cancellables)
    }

    // flatMapのクロージャ内で明示的に 戻り値の型 AnyPublisher<[Cocktail], Never> を指定しないと
    // Type of expression is ambiguous without more context　のエラーがでます
    func searchAction(query: String) -> AnyPublisher<[Cocktail], Error> {
        let escapedSearchTerm = searchWord.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        let url = URL(string: "https://www.thecocktaildb.com/api/json/v1/1/search.php?s=\(escapedSearchTerm)")!
        return URLSession.shared.dataTaskPublisher(for: url)
          .map(\.data)
          .decode(type: CocktailSearchResult.self, decoder: JSONDecoder())
          .map(\.drinks)
          .receive(on: DispatchQueue.main) // メインスレッドで値の発行を行う
          .catch { [weak self] error -> AnyPublisher<[Cocktail], Error> in
              // エラーハンドリング メインスレッドで行うようにする
              // Publishing changes from background threads is not allowed;
              // make sure to publish values from the main thread (via operators like receive(on:)) on model updates.
              self?.isSearching = false
              self?.showErrorAlert = true
              self?.error = error
              // 代替データを提供するか、エラーを投げるなどの処理を行う
              return Just([]).setFailureType(to: Error.self).eraseToAnyPublisher()
          }
          .eraseToAnyPublisher()
    }
    
    /*
    func searchAction(query: String) -> AnyPublisher<[Cocktail], Never> {
        return searchPublisher
            .flatMap { (query) -> AnyPublisher<[Cocktail], Never> in
                // ここで非同期処理を実行し、結果を生成するPublisherを返す
                let escapedSearchTerm = query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
                let url = URL(string: "https://www.thecocktaildb.com/api/json/v1/1/search.php?s=\(escapedSearchTerm)")!
                return URLSession.shared.dataTaskPublisher(for: url)
                    .map { $0.data }
                    .decode(type: CocktailSearchResult.self, decoder: JSONDecoder())
                    .map(\.drinks)
                    .replaceError(with: []) // Neverで返す場合はここが必要
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    */
}
