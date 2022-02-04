import Alamofire

public protocol GreetingService {
    func getGreeting(completion: @escaping (_ response: Result<String /* Greeting String */, Error>) -> Void)
}

class GreetingServiceImpl: GreetingService {
    private let authnService: AuthnService = AuthnServiceImpl()
    let url = "http://localhost:3000/v1/hello"
    
    
    func getGreeting(completion: @escaping (_ response: Result<String /* Greeting */, Error>) -> Void) {
        authnService.getToken { response in
            switch response {
            case let .failure(error):
                print(error)
                completion(.failure(error))
            case let .success(token):
                let headers: HTTPHeaders = [
                    "Authorization": "Bearer " + token
                ]
                AF.request(self.url, method: .get, headers: headers).validate(statusCode: 200..<300).responseDecodable(of: Greeting.self) { response in
                    switch response.result {
                    case let .success(greeting):
                        let msg = greeting.message
                        print("Recieved Greetings: ", msg)
                        completion(.success(msg))
                    case let .failure(error):
                        print("GreetingService Error: ", error)
                        completion(.failure(error))
                    }
                }
            }
        }
    }
}

private struct Greeting: Decodable {
    let message: String
}
