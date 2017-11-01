//
//  ViewController.swift
//  MoreRestPractice
//
//  Created by Jon Olivet on 4/25/17.
//  Copyright © 2017 Jon Olivet. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController {

  // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
  
  // MARK: - Actions
    @IBAction func alamoGetTapped(_ sender: UIButton) {
        let todoEndpoint: String = "https://jsonplaceholder.typicode.com/todos/1"
        Alamofire.request(todoEndpoint, method: .get).responseJSON { (response) in
            // handle JSON
            guard response.result.isSuccess else {
                print("response failed")
                return
            }
            guard response.result.error == nil else {
                print("error calling GET on /todos/1")
                print(response.result.error!)
                return
            }
            guard let json = response.result.value as? [String:Any] else {
                print("Didn't get todo object as JSON from API")
                print("Error: \(String(describing: response.result.error))")
                return
            }
            // get and print the title
            guard let todoTitle = json["title"] as? String else {
                print("Could not get todo title from JSON")
                return
            }
            print("the title is: " + todoTitle)
        }
    }
    @IBAction func alamoPostTapped(_ sender: UIButton) {
        let todosEndpoint: String = "https://jsonplaceholder.typicode.com/todos"
        let newTodo: [String:Any] = ["title":"My Second Post", "completed": 0, "userId": 1]
        Alamofire.request(todosEndpoint, method: .post, parameters: newTodo, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
            guard response.result.error == nil else {
                // got an error in getting the data, need to handle it
                print("error calling POST on /todos/1")
                print(response.result.error!)
                return
            }
            // make sure we got some JSON
            guard let json = response.result.value as? [String:Any] else {
                print("didn't get todo object as JSON from API")
                print("Error: \(String(describing: response.result.error))")
                return
            }
            // get and print the title
            guard let todoTitle = json["title"] as? String else {
                print("Could not get todo title from JSON")
            return
            }
            print("The title is: " + todoTitle)
        }
    }
    
    @IBAction func alamoDeleteTapped(_ sender: UIButton) {
        let firstTodoEndpoint: String = "https://jsonplaceholder.typicode.com/todos/1"
        Alamofire.request(firstTodoEndpoint, method: .delete).responseJSON { (response) in
            guard response.result.error == nil else {
                // got an error in getting the data, need to handle it
                print("error calling DELETE on /todos/1")
                print(response.result.error!)
                return
            }
            print("DELETE ok")
        }
    }

    @IBAction func doApiCall(_ sender: UIButton) {
        performGET()
    }
  
    @IBAction func postButtonTapped(_ sender: UIButton) {
        performPOST()
    }
    
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        performDelete()
    }
  
    func performGET(){
        let todoEndpoint: String = "https://jsonplaceholder.typicode.com/todos/1"
        
        guard let url = URL(string: todoEndpoint) else {
            print("Error: cannot create URL")
            return
        }
        
        let urlRequest = URLRequest(url: url)
        
        let session = URLSession.shared

        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            // check for any errors
            guard error == nil else {
                print("error calling GET on /todos/1")
                print(error!)
                return
            }
            //make sure we got data
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            //parse the result as JSON, since that's what the API provides
            do{
                guard let todo = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] else {
                    print("error trying to convert data to JSON")
                    return
                }
                // now we have the todo
                // lets just print it to prove we can access it
                print("The todo is: " + todo.description)
                
                // the todo object is a dictionary so we just access the title using the "title" key
                // so check for a title and print it if we have one
                guard let todoTitle = todo["title"] as? String else {
                    print("Could not get todo title from JSON")
                    return
                }
                print("The title is: " + todoTitle)
            } catch {
                print("error trying to convert data to JSON")
                return
            }
        }
        task.resume()
    }
    
    func performPOST(){
        let todosEndpoint: String = "https://jsonplaceholder.typicode.com/todos"
        guard let todosURL = URL(string: todosEndpoint) else {
            print("Error: cannot create URL")
            return
        }
        var todosUrlRequest = URLRequest(url: todosURL)
        todosUrlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        todosUrlRequest.httpMethod = "POST"
        
        let newTodo: [String: Any] = ["title": "My First todo", "completed": false, "userId": 1]
        let jsonTodo: Data
        do {
            jsonTodo = try JSONSerialization.data(withJSONObject: newTodo, options: [])
            todosUrlRequest.httpBody = jsonTodo
        } catch {
            print("Error: cannot create JSON from todo")
            return
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: todosUrlRequest) { (data, response, error) in
            guard error == nil else {
                print("error calling POST on /todos/1")
                print(error!.localizedDescription)
                return
            }
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            
            // parse the result as JSON, since that's what the API provides
            do{
                guard let receivedTodo = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] else {
                    print("Could not get JSON from responseData as dictionary")
                    // Got valid JSON but it isn't [String: Any]
                    print("JSON isn't a [String: Any]")
                    return
                }
                print("The todo is:  \(receivedTodo)")
                
                guard let todoID = receivedTodo["id"] as? Int else {
                    print("Could not get todoID as int from JSON")
                    return
                }
                print("The ID is: \(todoID)")
            } catch {
                print("error parsing response from POST on /todos")
                return
            }
        }
        task.resume()
    }
    
    func performDelete() {
        let firstTodoEndpoint: String = "https://jsonplaceholder.typicode.com/todos/1"
        guard let firstTodoURL = URL(string: firstTodoEndpoint) else {
            print("Error: cannot create URL")
            return
        }
        var firstTodoUrlRequest = URLRequest(url: firstTodoURL)
        firstTodoUrlRequest.httpMethod = "DELETE"
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: firstTodoUrlRequest) { (data, response, error) in
            guard let _ = data else {
                print("error calling DELETE on /todos/1")
                return
            }
            print("DELETE ok")
        }
        task.resume()
    }
  
}
